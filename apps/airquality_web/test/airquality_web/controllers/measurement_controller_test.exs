defmodule AirqualityWeb.MeasurementControllerTest do
  use AirqualityWeb.ConnCase

  import Mox
  import Airquality.Factory

  alias Airquality.Sources.OpenAQMock, as: Mock

  setup :verify_on_exit!

  describe "returns measurements" do
    test "when filtering by location id" do
      Mock
      |> expect(:get_latest_measurements, fn _id -> build_list(1, :measurement) end)

      conn = get(build_conn(), "api/measurements?filter[location]=1", [])

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "attributes" => %{
                     "parameter" => "pm10",
                     "unit" => "ppm",
                     "value" => 13.2,
                     "measured-at" => "2019-01-01T00:00:00Z"
                   },
                   "id" => "",
                   "type" => "measurement"
                 }
               ],
               "jsonapi" => %{"version" => "1.0"}
             }
    end
  end
end