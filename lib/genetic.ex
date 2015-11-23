defmodule Genetic do
  def start(target, max_population \\ 100, threshold \\ 90) do
    :random.seed(:erlang.system_time())
    len = String.length(target)
    generate_population(max_population, len) # Generate initial population
    |> assess(target, threshold) # Assess the population
    |> breed(target, threshold) # Start recursive loop of generating generations.
  end

  def generate_population(_, _, current \\ [])
  def generate_population(0, _, result), do: result
  def generate_population(population, length, current) do
    current = List.insert_at(current, 0, Random.string(length))
    generate_population(population-1, length, current)
  end

  def assess(chromosomes, target, threshold) do
    x = Parallel.pmap(chromosomes, fn(x) -> {x, fitness(x, target, threshold)} end)
    Enum.into(x, %{})
  end

  def breed(_, _, _, max_generations \\ 30000)
  def breed(population, _, _, 0), do: population
  def breed(population, target, threshold, max_generations) do
    #{parent1, parent2} = selection_process(population)

    # If elite, passthrough. Randomly crossover or mutate.
    #x = cross_over(parent1, parent2) |> assess(target, threshold)a

    #population = Map.delete(population, parent1)
    #population = Map.delete(population, parent2)
    #population = Map.merge(population, x)

    #Find elite of population
    best = elite(population, 10)
    #Randomly crossover(80%) or mutate(20%) the rest
    random = :random.uniform(100)
    if random >= 80 do
      #cross_over()
    else
      #mutate()
    end

    breed(population, target, threshold, max_generations-1)
  end

  def elite(population, amount) do
    # Given a population, and an amount of chromosomes.
    # Return that many best chromosomes.
    Enum.slice(List.keysort(population, 1), 0..amount-1)
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
    # Defines how genes are passed to next generation
    parent1 = elem(parent1,0)
    parent2 = elem(parent2,0)
    len = String.length(parent1)
    rand = :random.uniform(len)

    first1 = String.slice(parent1, 0..rand)
    last1 = String.slice(parent1, rand+1..len)

    first2 = String.slice(parent2, 0..rand)
    last2 = String.slice(parent2, rand+1..len)

    [mutate(first1 <> last2), mutate(first2 <> last1)]
  end

  def selection_process(population) do
    parent1 = Enum.random(population)
    parent2 = Enum.random(population)
    parent3 = Enum.random(population)
    parent4 = Enum.random(population)

    # Return the two superior parents
    {select_fitter_mate(parent1, parent2), select_fitter_mate(parent3, parent4)}
  end

  def mutate(input) do
    random = :random.uniform(100)
    if random >= 80 do
      random = :random.uniform(String.length(input)-1)
      String.replace(input, String.at(input, random), Random.letter(), global: false)
    else
      input
    end
  end

  # Evaluate the fitness of the possible solution
  def fitness(chromosome, target, threshold) do
    c = Enum.with_index(String.codepoints(chromosome))
    t = Enum.with_index(String.codepoints(target))

    x = fitness_helper(c,t)
    if x <= threshold do
      IO.puts("Found Chromosome: '#{chromosome}' with fitness #{x} that crosses theshold: #{threshold} for target: #{target}")
    else
      x
    end
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

#Genetic.start("Hello World", 100,  100)
#Genetic.fitness("heRlo World", "Hello World",  100)
IO.puts Genetic.elite([{"test", 10}, {"testing", 5}, {"this", 15}, {"te", 1}], 3)

