defmodule Shared.EventStoreListener do
  use GenServer
  require Logger
  alias EventStore.RecordedEvent

  @type domain_event :: struct()
  @type metadata :: map()
  @type failure_context :: map()
  @type state :: map() | list()
  @type handle_result :: :ok | {:error, reason :: any()}

  @callback handle(domain_event(), metadata()) :: handle_result()
  @callback handle(domain_event(), metadata(), state()) :: handle_result()
  @callback on_error(
              error :: term(),
              failed_event :: domain_event(),
              metadata :: metadata(),
              failure_context :: failure_context()
            ) ::
              {:retry, failure_context :: failure_context()}
              | {:retry, delay :: non_neg_integer(), failure_context :: failure_context()}
              | :skip
              | {:stop, reason :: term()}

  @callback on_error(
              error :: term(),
              stacktrace :: list(),
              failed_event :: domain_event(),
              metadata :: metadata(),
              failure_context :: failure_context()
            ) ::
              {:retry, failure_context :: failure_context()}
              | {:retry, delay :: non_neg_integer(), failure_context :: failure_context()}
              | :skip
              | {:stop, reason :: term()}

  defmacro __using__(opts) do
    opts = opts || []

    quote location: :keep do
      @opts unquote(opts) || []
      @name @opts[:name] || __MODULE__

      @behaviour Shared.EventStoreListener

      # Verhindere, dass`@subscription_key` eine Warnung produzieren, falls nicht gesetzt.
      unless Module.get_attribute(__MODULE__, :subscription_key) do
        Module.put_attribute(__MODULE__, :subscription_key, nil)
      end

      # Adds default handle method
      @before_compile unquote(__MODULE__)

      def start_link(opts \\ []) do
        opts = Keyword.merge(@opts, opts)
        Shared.EventStoreListener.start_link(@name, __MODULE__, opts)
      end

      def child_spec(opts) do
        default = %{
          id: @name,
          start: {__MODULE__, :start_link, [opts]},
          restart: :permanent,
          type: :worker
        }

        Supervisor.child_spec(default, [])
      end
    end
  end

  def start_link(name, handler_module, opts) do
    default_opts = %{
      name: nil,
      handler_module: nil,
      subscription_key: nil,
      subscription: nil,
      start_from: :origin
    }

    opts = Enum.into(opts, default_opts)

    state = %{opts | handler_module: handler_module, name: name}

    GenServer.start_link(__MODULE__, state, name: name)
  end

  defmacro __before_compile__(_env) do
    quote generated: true do
      def init(state) do
        state =
          case @subscription_key do
            subscription_key when is_binary(subscription_key) and subscription_key != "" ->
              %{state | subscription_key: subscription_key}

            _ ->
              state
          end

        {:ok, state}
      end

      defoverridable init: 1

      def handle(_event, _metadata), do: :ok
      defoverridable handle: 2

      def handle(event, metadata, _state), do: handle(event, metadata)
      defoverridable handle: 3

      def on_error({:error, reason}, _event, _metadata, _context), do: {:stop, reason}
      defoverridable on_error: 4

      def on_error(error, _stacktrace, event, metadata, context),
        do: on_error(error, event, metadata, context)

      defoverridable on_error: 5
    end
  end

  @impl true
  def init(%{name: handler_name, handler_module: handler_module} = state) do
    with {:ok, new_state} <- handler_module.init(state),
         subscription_key = new_state[:subscription_key] || subscription_key_for(handler_name),
         start_from = new_state[:start_from] || :origin,
         {:ok, subscription} <-
           EventStore.subscribe_to_all_streams(
             subscription_key,
             self(),
             start_from: start_from
           ) do
      {:ok, %{new_state | subscription: subscription}}
    end
  end

  @impl true
  def handle_info({:subscribed, _subscription}, %{name: name} = state) do
    Logger.debug(fn ->
      "#{name} sucessfully subscribed to event store."
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info({:events, events}, %{name: name} = state) do
    Logger.debug(fn -> "#{name} received events: #{inspect(events)}" end)

    try do
      Enum.each(events, fn event -> handle_event(event, state, Map.new()) end)
      {:noreply, state}
    catch
      {:error, reason} ->
        {:stop, reason, state}
    end
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state}
  end

  defp handle_event(
         %RecordedEvent{} = event,
         %{name: name} = state,
         %{} = context
       ) do
    case delegate_event_to_handler(event, state) do
      :ok ->
        ack_event(event, state)

      {:error, reason} = error ->
        Logger.error(fn ->
          "#{name} failed to handle event #{inspect(event)} due to #{inspect(reason)}"
        end)

        handle_error(error, nil, event, state, context)

      {:error, reason, stacktrace} = error ->
        Logger.error(fn ->
          "#{name} failed to handle event #{inspect(event)} due to #{inspect(reason)}"
        end)

        error = Tuple.delete_at(error, 2)
        handle_error(error, stacktrace, event, state, context)
    end
  end

  defp delegate_event_to_handler(
         %RecordedEvent{} = event,
         %{
           handler_module: handler_module
         } = state
       ) do
    try do
      {domain_event, metadata} = Shared.EventStoreEvent.unwrap(event)
      handler_module.handle(domain_event, metadata, state)
    rescue
      error ->
        {:error, error, __STACKTRACE__}
    end
  end

  defp handle_error(
         error,
         stacktrace,
         event,
         %{handler_module: handler_module, name: name} = state,
         context
       ) do
    %RecordedEvent{data: domain_event, metadata: metadata} = event

    case handler_module.on_error(error, stacktrace, domain_event, metadata, context) do
      {:retry, context} when is_map(context) ->
        Logger.debug(fn ->
          "#{name} is retrying failed event #{inspect(event)}"
        end)

        handle_event(event, state, context)

      {:retry, delay, context} when is_map(context) and is_integer(delay) and delay > 0 ->
        Logger.debug(fn ->
          "#{name} is retrying failed event #{inspect(event)} after #{delay}ms"
        end)

        :timer.sleep(delay)
        handle_event(event, state, context)

      :skip ->
        Logger.debug(fn ->
          "#{name} is skipping event #{inspect(event)}"
        end)

        ack_event(event, state)

      {:stop, reason} ->
        Logger.warn(fn ->
          "#{name} has requested to stop with #{inspect(reason)}"
        end)

        throw({:error, reason})

      error ->
        Logger.warn(fn ->
          "#{name} returned an invalid response #{inspect(error)}"
        end)

        throw(error)
    end
  end

  defp ack_event(event, %{subscription: subscription}) do
    :ok = EventStore.ack(subscription, event)
  end

  @deprecated """
  Set `subscription_key` on initialization. Otherwise a change of the file name would break the subscription and all the events get processed again.
  """
  defp subscription_key_for(handler) do
    subscription_key =
      handler
      |> Atom.to_string()
      |> String.split(".")
      |> Enum.at(-1)
      |> Macro.underscore()
      |> Kernel.<>("_event_listener")

    Logger.warn(
      "Please specify a `subscription_key` on initialization for `#{handler}`. Otherwise a change of the file name would break the subscription and all the events get processed again. Default was: \"#{
        subscription_key
      }\""
    )

    subscription_key
  end
end
