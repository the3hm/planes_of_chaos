defmodule Kantele.Brain do
  @moduledoc """
  Load and parse brain data into behavior tree structs
  """

  @brains_path "data/brains"

  alias Kalevala.Brain
  alias Kalevala.Brain.Nodes.{
    NullNode,
    Sequence,
    FirstSelector,
    ConditionalSelector,
    Condition,
    StateSet,
    Action
  }

  @doc """
  Load brain data from the path

  Defaults to `#{@brains_path}`
  """
  def load_all(path \\ @brains_path) do
    File.ls!(path)
    |> Enum.filter(&String.ends_with?(&1, ".ucl"))
    |> Enum.map(&File.read!(Path.join(path, &1)))
    |> Enum.map(&Elias.parse/1)
    |> Enum.flat_map(&merge_data/1)
    |> Enum.into(%{})
  end

  defp merge_data(brain_data) do
    Enum.map(brain_data.brains, fn {key, value} ->
      {to_string(key), value}
    end)
  end

  def process_all(brains) do
    Enum.into(brains, %{}, fn {key, value} ->
      {key, process(value, brains)}
    end)
  end

  def process(brain, brains) when brain != nil do
    %Brain{
      root: parse_node(brain, brains)
    }
  end

  def process(_, _brains) do
    %Brain{
      root: %NullNode{}
    }
  end

  # Handle "brains.town_crier"
  defp parse_node("brains." <> key_path, brains) do
    parse_node(brains[key_path], brains)
  end

  # Handle references like %{ref: "brains.town_crier"}
  defp parse_node(%{ref: "brains." <> key_path}, brains) do
    parse_node(brains[key_path], brains)
  end

  defp parse_node(%{type: "sequence", nodes: nodes}, brains) do
    %Sequence{nodes: Enum.map(nodes, &parse_node(&1, brains))}
  end

  defp parse_node(%{type: "first", nodes: nodes}, brains) do
    %FirstSelector{nodes: Enum.map(nodes, &parse_node(&1, brains))}
  end

  defp parse_node(%{type: "conditional", nodes: nodes}, brains) do
    %ConditionalSelector{nodes: Enum.map(nodes, &parse_node(&1, brains))}
  end

  defp parse_node(%{type: "conditions/" <> type} = condition, brains),
    do: parse_condition(type, condition, brains)

  defp parse_node(%{type: "actions/" <> type} = action, brains),
    do: parse_action(type, action, brains)

  @doc """
  Process a condition
  """
  def parse_condition("message-match", %{data: data}, _brains) do
    {:ok, regex} = Regex.compile(data.text, "i")

    %Condition{
      type: Kalevala.Brain.Conditions.MessageMatch,
      data: %{
        interested?: &Kantele.Character.SayEvent.interested?/1,
        self_trigger: data.self_trigger == "true",
        text: regex
      }
    }
  end

  def parse_condition("tell-match", %{data: data}, _brains) do
    {:ok, regex} = Regex.compile(data.text, "i")

    %Condition{
      type: Kalevala.Brain.Conditions.MessageMatch,
      data: %{
        interested?: &Kantele.Character.TellEvent.interested?/1,
        self_trigger: data.self_trigger == "true",
        text: regex
      }
    }
  end

  def parse_condition("state-match", %{data: data}, _brains) do
    %Condition{
      type: Kalevala.Brain.Conditions.StateMatch,
      data: data
    }
  end

  def parse_condition("room-enter", %{data: data}, _brains) do
    %Condition{
      type: Kalevala.Brain.Conditions.EventMatch,
      data: %{
        self_trigger: data.self_trigger == "true",
        topic: Kalevala.Event.Movement.Notice,
        data: %{direction: :to}
      }
    }
  end

  def parse_condition("event-match", %{data: data}, _brains) do
    %Condition{
      type: Kalevala.Brain.Conditions.EventMatch,
      data: %{
        self_trigger: Map.get(data, :self_trigger, "false") == "true",
        topic: data.topic,
        data: Map.get(data, :data, %{})
      }
    }
  end

  @doc """
  Process actions
  """
  def parse_action("state-set", action, _brains) do
    %StateSet{data: action.data}
  end

  def parse_action("say", action, _brains) do
    %Action{
      type: Kantele.Character.SayAction,
      data: action.data,
      delay: Map.get(action, :delay, 0)
    }
  end

  def parse_action("emote", action, _brains) do
    %Action{
      type: Kantele.Character.EmoteAction,
      data: action.data,
      delay: Map.get(action, :delay, 0)
    }
  end

  def parse_action("flee", action, _brains) do
    %Action{
      type: Kantele.Character.FleeAction,
      data: %{},
      delay: Map.get(action, :delay, 0)
    }
  end

  def parse_action("wander", action, _brains) do
    %Action{
      type: Kantele.Character.WanderAction,
      data: %{},
      delay: Map.get(action, :delay, 0)
    }
  end

  def parse_action("delay-event", action, _brains) do
    %Action{
      type: Kantele.Character.DelayEventAction,
      data: action.data,
      delay: Map.get(action, :delay, 0)
    }
  end
end
