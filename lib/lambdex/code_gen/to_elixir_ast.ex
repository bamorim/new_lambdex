defmodule Lambdex.CodeGen.ToElixirAst do
  alias Lambdex.AST
  alias AST.{Def, Expr, Mod}
  alias Expr.{App, Lam, Var}
  @spec generate(AST.t()) :: Macro.t()
  def generate(%Mod{name: name, defs: defs}) do
    expr_defs = Enum.map(defs, &generate/1)

    quote do
      defmodule unquote(name) do
        def __lambdex_defs__ do
          unquote(expr_defs)

          unquote(
            Enum.map(defs, fn %{name: name} ->
              {name, Macro.var(name, nil)}
            end)
          )
        end

        # Export as elixir functions (0 arity)
        unquote(
          Enum.map(defs, fn %{name: name} ->
            quote do
              def unquote(Macro.var(name, nil)) do
                Keyword.get(__lambdex_defs__(), unquote(name))
              end
            end
          end)
        )
      end
    end
  end

  def generate(%Def{name: name, expr: expr}) do
    quote do
      unquote(Macro.var(name, nil)) = unquote(generate(expr))
    end
  end

  def generate(%Var{var: var}) do
    Macro.var(var, nil)
  end

  def generate(%Lam{var: var, body: body}) do
    quote do
      fn unquote(Macro.var(var, nil)) ->
        unquote(generate(body))
      end
    end
  end

  def generate(%App{fun: fun, arg: arg}) do
    quote do
      unquote(generate(fun)).(unquote(generate(arg)))
    end
  end
end
