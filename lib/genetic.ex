defmodule Genetic do
  def start(target, max_population \\ 100, threshold \\ 90) do
    :random.seed(:erlang.system_time())
    len = String.length(target)
    generate_population(max_population, len) # Generate initial population
    |> assess(target, threshold) # Assess the population
    |> breed(target, threshold) # Start recursive loop of generating generations.
  end

  def generate_population(population, length) do
    for _chromosome <- 0..population, do: Random.string(length)
  end

  def assess(chromosomes, target, threshold) do
    Parallel.pmap(chromosomes, fn(x) -> {x, fitness(x, target, threshold)} end)
  end

  def breed(_, _, _, max_generations \\ 2000)
  def breed(population, _, _, 0), do: population
  def breed(population, target, threshold, max_generations) do
    IO.puts 2000-max_generations
    filter_list(population, target, threshold)
    |> breed(target, threshold, max_generations-1)
  end

  def filter_list(population, target, threshold) do
    filtered_list = elite(population, div(length(population),10))
    best = elem(filtered_list, 0)
    the_rest = elem(filtered_list, 1)
    the_rest = best ++ Enum.slice(the_rest, 0, length(the_rest)-length(best))

    best ++ handle_the_rest(the_rest, target, threshold)
  end

  def handle_the_rest(population, target, threshold) do
    Parallel.pmap(population, fn(x) ->
      x = elem(x,0)
      random = :random.uniform(100)
      if random >= 80 do
        mutate(x)
      else
        x
      end
    end)
    |> cross_over_helper
    |> assess(target, threshold)
  end

  def cross_over_helper(_, current \\ [])
  def cross_over_helper([head|tail], current) do
    random = :random.uniform(100)
      if random <= 80 do
        case tail do
          [] ->
            current = List.insert_at(current, 0, head)
            cross_over_helper(tail, current)
          _  ->
            children = hd(List.insert_at(current, 0, cross_over(head, hd(tail))))
            current = current ++ children
            cross_over_helper(tl(tail), current)
        end
      else
        current = List.insert_at(current, 0, head)
        cross_over_helper(tail, current)
      end
  end
  def cross_over_helper([], result), do: result

  def elite(population, amount) do
    x = List.keysort(population, 1)
    {Enum.slice(x, 0..amount-1), Enum.slice(x, amount..length(x)-1)}
  end

  def select_fitter_mate(parent1, parent2) do
    score1 = elem(parent1, 1)
    score2 = elem(parent2, 1)
    if score1 <= score2 do
      parent1
    else
      parent2
    end
  end

  def cross_over(parent1, parent2) do
    len = String.length(parent1)
    rand = :random.uniform(len)

    first1 = String.slice(parent1, 0..rand)
    last1 = String.slice(parent1, rand+1..len)

    first2 = String.slice(parent2, 0..rand)
    last2 = String.slice(parent2, rand+1..len)

    [first1 <> last2, first2 <> last1]
  end

  def selection_process(population) do
    parent1 = Enum.random(population)
    parent2 = Enum.random(population)
    parent3 = Enum.random(population)
    parent4 = Enum.random(population)

    [select_fitter_mate(parent1, parent2), select_fitter_mate(parent3, parent4)]
  end

  def mutate(input) do
    random = :random.uniform(String.length(input)-1)
    String.replace(input, String.at(input, random), Random.letter(), global: false)
  end

  def fitness(chromosome, target, threshold) do
    c = String.codepoints(chromosome) |> Enum.with_index()
    t = String.codepoints(target) |> Enum.with_index()

    x = fitness_helper(c,t)
    if x <= threshold do
      IO.puts("Found Chromosome: '#{chromosome}' with fitness #{x} that crosses theshold: #{threshold} for target: #{target}")
      System.halt(0)
    end
    x
  end

  def fitness_helper(_, _, score \\ 0)
  def fitness_helper([chead|ctail], [thead|ttail], score) do
    << value1 :: utf8 >> = elem(chead, 0)
    << value2 :: utf8 >> = elem(thead, 0)
    score = score + abs(value2 - value1)

    fitness_helper(ctail, ttail, score)
  end
  def fitness_helper([], [], score) do
    score
  end
end

Genetic.start("Hello World", 5000, 0)

