defmodule Breethe.SourcesTest do
  use Breethe.DataCase

  import Mox
  import Breethe.Factory

  alias Breethe.{Sources, TaskSupervisor}
  alias Breethe.Sources.{OpenAQMock, GoogleMock}

  require IEx

  setup :set_mox_global
  setup :verify_on_exit!

  describe "get_data(cached_locations, search_term), location is in the EEA list:" do
    test "no-op and returns cached_locations" do
      search_term = "Munich"
      expect(GoogleMock, :find_location_country_code, fn ^search_term -> "DE" end)

      assert [] = Sources.get_data([], search_term)
    end
  end

  describe "get_data(cached_locations, search_term), location isn't in the EEA list:" do
    test "returns OpenAQ locations if cached_locations list is empty" do
      search_term = "Portland"

      expect(GoogleMock, :find_location_country_code, fn ^search_term -> "US" end)
      expect(OpenAQMock, :get_locations, fn ^search_term -> [] end)

      assert [] = Sources.get_data([], search_term)
    end

    test "returns OpenAQ locations if cached_locations list is smaller than 10" do
      search_term = "Portland"

      cached_locations = [insert(:location)]
      open_aq_locations = build_list(3, :location)

      expect(GoogleMock, :find_location_country_code, fn ^search_term -> "US" end)
      expect(OpenAQMock, :get_locations, fn ^search_term -> open_aq_locations end)

      returned_locations = Sources.get_data(cached_locations, search_term)
      stop_background_tasks()

      assert open_aq_locations == returned_locations
    end

    test "starts a background task for measurements if cached_locations list is smaller than 10" do
      search_term = "Portland"

      cached_locations = [insert(:location)]
      open_aq_locations = build_list(3, :location)

      stub(GoogleMock, :find_location_country_code, fn ^search_term -> "US" end)

      OpenAQMock
      |> stub(:get_locations, fn ^search_term -> open_aq_locations end)
      |> expect(:get_latest_measurements, length(open_aq_locations), fn _location_id -> [] end)

      Sources.get_data(cached_locations, "Portland")

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end

    test "no-op and returns cached_locations if locations list is larger than 10" do
      search_term = "Portland"

      cached_locations = insert_list(10, :location)
      open_aq_locations = build_list(2, :location)

      expect(GoogleMock, :find_location_country_code, fn ^search_term -> "US" end)

      OpenAQMock
      |> stub(:get_locations, fn ^search_term -> open_aq_locations end)
      |> stub(:get_latest_measurements, fn _location_id -> [] end)

      returned_locations = Sources.get_data(cached_locations, search_term)
      stop_background_tasks()

      assert cached_locations == returned_locations
    end

    test "starts background tasks for locations and measurements if cached_locations list is larger than 10" do
      search_term = "Portland"

      cached_locations = insert_list(10, :location)
      open_aq_locations = build_list(2, :location)

      expect(GoogleMock, :find_location_country_code, fn ^search_term -> "US" end)

      OpenAQMock
      |> expect(:get_locations, fn ^search_term -> open_aq_locations end)
      |> expect(:get_latest_measurements, length(cached_locations), fn _location_id -> [] end)

      Sources.get_data(cached_locations, search_term)

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end
  end

  describe "get_data(cached_locations, lat, lon), location is in the EEA list:" do
    test "no-op and returns cached_locations" do
      lat = 0.0
      lon = 0.0

      expect(GoogleMock, :find_location_country_code, fn ^lat, ^lon -> "DE" end)

      assert [] = Sources.get_data([], lat, lon)
    end
  end

  describe "get_data(cached_locations, lat, lon), location isn't the EEA list:" do
    test "returns OpenAQ locations if cached_locations list is empty" do
      lat = 0.0
      lon = 0.0

      expect(GoogleMock, :find_location_country_code, fn ^lat, ^lon -> "US" end)
      expect(OpenAQMock, :get_locations, fn ^lat, ^lon -> [] end)

      assert [] = Sources.get_data([], lat, lon)
    end

    test "returns OpenAQ locations if cached_locations list is smaller than 10" do
      lat = 0.0
      lon = 0.0

      cached_locations = [insert(:location)]
      open_aq_locations = build_list(3, :location)

      expect(GoogleMock, :find_location_country_code, fn ^lat, ^lon -> "US" end)
      expect(OpenAQMock, :get_locations, fn ^lat, ^lon -> open_aq_locations end)

      returned_locations = Sources.get_data(cached_locations, lat, lon)
      stop_background_tasks()

      assert open_aq_locations == returned_locations
    end

    test "starts a background task for measurements if cached_locations list is smaller than 10" do
      lat = 0.0
      lon = 0.0

      cached_locations = [insert(:location)]
      open_aq_locations = build_list(3, :location)

      stub(GoogleMock, :find_location_country_code, fn ^lat, ^lon -> "US" end)

      OpenAQMock
      |> stub(:get_locations, fn ^lat, ^lon -> open_aq_locations end)
      |> expect(:get_latest_measurements, length(open_aq_locations), fn _location_id -> [] end)

      Sources.get_data(cached_locations, lat, lon)

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end

    test "no-op and returns cached_locations if locations list is larger than 10" do
      lat = 0.0
      lon = 0.0

      cached_locations = insert_list(10, :location)
      open_aq_locations = build_list(2, :location)

      expect(GoogleMock, :find_location_country_code, fn ^lat, ^lon -> "US" end)

      OpenAQMock
      |> stub(:get_locations, fn ^lat, ^lon -> open_aq_locations end)
      |> stub(:get_latest_measurements, fn _location_id -> [] end)

      returned_locations = Sources.get_data(cached_locations, lat, lon)
      stop_background_tasks()

      assert cached_locations == returned_locations
    end

    test "starts background tasks for locations and measurements if cached_locations list is larger than 10" do
      lat = 0.0
      lon = 0.0

      cached_locations = insert_list(10, :location)
      open_aq_locations = build_list(2, :location)

      expect(GoogleMock, :find_location_country_code, fn ^lat, ^lon -> "US" end)

      OpenAQMock
      |> expect(:get_locations, fn ^lat, ^lon -> open_aq_locations end)
      |> expect(:get_latest_measurements, length(cached_locations), fn _location_id -> [] end)

      Sources.get_data(cached_locations, lat, lon)

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end
  end

  defp stop_background_tasks() do
    TaskSupervisor
    |> Task.Supervisor.children()
    |> Enum.each(fn task ->
      Task.Supervisor.terminate_child(TaskSupervisor, task)
    end)
  end
end
