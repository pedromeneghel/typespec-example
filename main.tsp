import "@typespec/http";

using TypeSpec.Http;

@doc("""
  This is a sample Car Rental API based on the OpenAPI 3.0 specification. You can find out more about
   - Swagger at [https://swagger.io](https://swagger.io).
  """)
@service({
  title: "Car Rental API",
})
@server("http://localhost:8080", "Development")
@server("http://prod.system.com", "Production")
namespace RentalCar;

model CustomerModel {
  id: int64;

  @minLength(3)
  @maxLength(255)
  name: string;

  @format("email")
  @pattern(".+\@.+\\..+")
  email: string;

  @maxLength(11)
  @pattern("^[0-9]+$")
  document: string;

  @minLength(1)
  @maxLength(255)
  street: string;

  @minLength(1)
  @maxLength(20)
  number?: string;

  @minLength(1)
  @maxLength(100)
  neighborhood: string;

  @minLength(1)
  @maxLength(8)
  @pattern("^[0-9]+$")
  zipcode: string;
}

@summary("Car object")
@doc("Car attributes")
model CarModel {
  id: int64;

  @minLength(1)
  @maxLength(100)
  @example("Ford")
  @summary("Maker")
  @doc("Car maker")
  brand: string;

  @minLength(1)
  @maxLength(20)
  version: string;

  @minValue(2000)
  year: int64;

  @minLength(1)
  @maxLength(255)
  otherDetails?: string;
}

enum RentalStatus {
  pending: "pending",
  completed: "completed",
  canceled: "canceled",
  inProgress: "inProgress",
}

model RentalCarModel {
  id: int64;
  customerId: int64;
  carId: int64;
  rentalDate: utcDateTime;
  returnDate: utcDateTime;
  totalValue: float64;
  status: RentalStatus;

  @minLength(1)
  @maxLength(255)
  otherDetails?: string;
}

model RentalStatusModel {
  status: RentalStatus;
}

model RequestBodyGenericModel<Model> {
  ...OmitProperties<Model, "id">;
}

@route("/customer")
@tag("Customer management")
interface Customers {
  @post
  @useAuth(BearerAuth)
  create(@body customer: RequestBodyGenericModel<CustomerModel>): {
    @statusCode statusCode: 201;
    @body customer: CustomerModel;
  } | {
    @statusCode statusCode: 400;
    @body error: ValidationError;
  } | {
    @statusCode statusCode: 500;
  };

  @get
  list(): {
    @statusCode statusCode: 200;
    @body customer: CustomerModel[];
  };

  @get
  read(@path customerId: int64): {
    @statusCode statusCode: 200;
    @body customer: CustomerModel;
  };

  @delete
  @useAuth(BearerAuth)
  delete(@path customerId: int64): {
    @statusCode statusCode: 204;
  };
}

@route("/car")
@tag("Car management")
interface Cars {
  @post
  @useAuth(BearerAuth)
  create(@body car: RequestBodyGenericModel<CarModel>): {
    @statusCode statusCode: 201;
    @body car: CarModel;
  };

  @get
  list(): {
    @statusCode statusCode: 200;
    @body car: CarModel[];
  };

  @get
  read(@path carId: int64): {
    @statusCode statusCode: 200;
    @body car: CarModel;
  };

  @delete
  @useAuth(BearerAuth)
  delete(@path carId: int64): {
    @statusCode statusCode: 204;
  };
}

@route("/rental")
@tag("Rental management")
interface Rentals {
  @post
  @useAuth(BearerAuth)
  create(@body rental: RequestBodyGenericModel<RentalCarModel>): {
    @statusCode statusCode: 201;
    @body rental: RentalCarModel;
  };

  @get
  list(): {
    @statusCode statusCode: 200;
    @body rental: RentalCarModel[];
  };

  @get
  read(@path rentalId: int64): {
    @statusCode statusCode: 200;
    @body rental: RentalCarModel;
  };

  @patch
  @useAuth(BearerAuth)
  update(@path rentalId: int64, @body rentalStatus: RentalStatusModel): {
    @statusCode statusCode: 201;
    @body rental: RentalCarModel;
  };
}

@error
model ValidationError {
  code: "VALIDATION_ERROR";
  message: string;
  details: string[];
}
