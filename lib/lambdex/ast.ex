defmodule Lambdex.AST do
  import Algae
  alias __MODULE__

  @type t :: Expr.t() | Mod.t() | Def.t()

  defmodule Expr do
    defsum do
      defdata(Var :: atom() \\ :x)

      defdata Lam do
        var :: atom() \\ :x
        body :: Expr.t() \\ Expr.Var.new(:x)
      end

      defdata App do
        fun :: Expr.t() \\ Expr.Lam.new()
        arg :: Expr.t() \\ Expr.Lam.new()
      end
    end
  end

  defdata Def do
    name :: atom() \\ :x
    expr :: Expr.t() \\ AST.Expr.Lam.new()
  end

  defdata Mod do
    name :: atom() \\ :MyMod
    defs :: [Def.t()] \\ [AST.Def.new()]
  end
end
