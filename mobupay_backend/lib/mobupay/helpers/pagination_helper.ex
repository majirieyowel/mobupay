defmodule Mobupay.Helpers.Pagination do
  def format(key, data) when is_bitstring(key) do
    %{
      key => data.entries,
      "page_number" => data.page_number,
      "page_size" => data.page_size,
      "total_pages" => data.total_pages,
      "total_entries" => data.total_entries
    }
  end

  def format(key, data) when is_atom(key), do: format(Atom.to_string(key), data)
end
