defmodule Lambdex.CodeGen.ToJS do
  alias Lambdex.AST
  alias AST.{Def, Expr, Mod}
  alias Expr.{App, Lam, Var}
  @spec generate(AST.t()) :: Macro.t()
  def generate(%Mod{name: name, defs: defs}) do
    """
    const #{name} = (() => {
      #{defs |> Enum.map(&generate/1) |> Enum.join("\n  ")}

      return {#{defs |> Enum.map(& &1.name) |> Enum.join(", ")}}
    })()
    """
  end

  def generate(%Def{name: name, expr: expr}) do
    "#{name} = #{generate(expr)}"
  end

  def generate(%Var{var: var}) do
    "#{var}"
  end

  def generate(%Lam{var: var, body: body}) do
    "(#{var}) => (#{generate(body)})"
  end

  def generate(%App{fun: fun, arg: arg}) do
    "(#{generate(fun)})(#{generate(arg)})"
  end
end
