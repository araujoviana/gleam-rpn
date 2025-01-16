//// A Reverse Polish Notation calculator written in Gleam.

import gleam/bool
import gleam/erlang
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

type Stack =
  List(Int)

pub fn main() {
  io.println("Welcome! You can exit with 'q'")
  repl()
}

fn repl() {
  let input: List(String) = get_input()
  use <- bool.guard(when: input == ["q"], return: 0)
  let result: Int = parse_stack([], input)
  io.debug(result)
  repl()
}

fn get_input() {
  // -> List(String) {
  erlang.get_line("$ ")
  |> result.unwrap("q")
  |> string.lowercase()
  |> string.drop_end(1)
  |> string.split(on: " ")
  |> list.filter(fn(x) { is_valid_symbol(x) || is_number(x) })
}

fn parse_stack(stack: Stack, input input: List(String)) -> Int {
  case input {
    [first] ->
      case is_valid_symbol(first) {
        True ->
          push_or_pop(first, stack) |> parse_stack(input: list.drop(input, 1))
        False -> result.unwrap(int.parse(first), 0)
      }
    [first, ..] ->
      push_or_pop(first, stack) |> parse_stack(input: list.drop(input, 1))
    [] -> result.unwrap(list.first(stack), 0)
  }
}

fn push_or_pop(first: String, stack: Stack) -> Stack {
  case is_valid_symbol(first) {
    True -> pop_and_calculate(first, stack)
    // Operator
    False -> push(result.unwrap(int.parse(first), 0), stack)
    // Number
  }
}

fn push(value: Int, stack: Stack) -> Stack {
  list.append(stack, [value])
}

fn pop_and_calculate(operator: String, stack: Stack) -> Stack {
  let assert [x, y]: List(Int) = case stack {
    [x, y] | [x, y, ..] -> [x, y]
    _ -> [0, 0]
  }
  let result: Int = case operator {
    "+" -> x + y
    "-" -> x - y
    "*" -> x * y
    "/" -> x / y
    _ -> 0
  }
  let stack = list.drop(stack, 2)

  push(result, stack)
}

fn is_valid_symbol(x: String) -> Bool {
  case x {
    "+" | "-" | "*" | "/" -> True
    "q" -> True
    _ -> False
  }
}

fn is_number(x: String) -> Bool {
  result.is_ok(int.parse(x))
}
