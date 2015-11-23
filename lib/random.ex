defmodule Random do

  @allowed_chars " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "

  def letter() do
    random = :random.uniform(String.length(@allowed_chars)-1)
    String.at(@allowed_chars, random)
  end

  def string(_, current \\ "")
  def string(0, result), do: result

  def string(length, current) do
    random = :random.uniform(String.length(@allowed_chars)-1)
    current = current <> String.at(@allowed_chars, random)
    string(length-1, current)
  end
end

