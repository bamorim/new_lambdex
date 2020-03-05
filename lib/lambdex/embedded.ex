defmodule Lambdex.Embedded do
  alias Lambdex.AST
  alias AST.{Def, Expr, Mod}
  alias Expr.{App, Lam, Var}
  alias Lambdex.CodeGen.ToElixirAst

  @doc "Use elixir syntax directly"
  defmacro deflambdexmod(name, generator \\ ToElixirAst, do: block) do
    name = Macro.expand(name, __CALLER__)
    generator = Macro.expand(generator, __CALLER__)

    lambdex_ast = %Mod{
      name: name,
      defs: List.wrap(parse(block))
    }

    generator.generate(lambdex_ast)
  end

  defp parse({:__block__, _, defs}) do
    Enum.map(defs, &parse/1)
  end

  defp parse({:=, _, [{name, _, nil}, expr]}) do
    %Def{name: name, expr: parse(expr)}
  end

  defp parse({:., _, [fun, arg]}) do
    %App{fun: parse(fun), arg: parse(arg)}
  end

  defp parse({var, _, nil}) do
    %Var{var: var}
  end

  defp parse({lam, _, [body]}) do
    case to_string(lam) do
      "λ" <> var -> %Lam{var: :"#{var}", body: parse(body)}
    end
  end
end
