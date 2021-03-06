defmodule Meilisearch.UpdateTest do
  use ExUnit.Case
  alias Meilisearch.{Document, Index, Update}

  @test_index Application.get_env(:meilisearch, :test_index)
  @test_document %{
    id: 100,
    title: "The Thing",
    tagline: "Man is the warmest place to hide"
  }

  setup_all do
    Index.delete(@test_index)
    Index.create(@test_index)

    on_exit(fn ->
      Index.delete(@test_index)
    end)

    :ok
  end

  describe "Update.get" do
    test "returns error, 404 with invalid update id" do
      {:error, status_code, message} = Update.get(@test_index, 10_071_982)

      assert status_code == 404
      assert is_binary(message)
    end

    test "returns update status" do
      {:ok, %{"updateId" => update_id}} = Document.add_or_replace(@test_index, [@test_document])

      assert {:ok,
              %{
                "enqueuedAt" => _,
                "status" => _,
                "type" => _,
                "updateId" => _
              }} = Update.get(@test_index, update_id)
    end
  end

  test "Update.list returns list of updates" do
    Document.add_or_replace(@test_index, [@test_document])
    {:ok, [update | _]} = Update.list(@test_index)

    assert %{
             "enqueuedAt" => _,
             "status" => _,
             "type" => _,
             "updateId" => _
           } = update
  end
end
