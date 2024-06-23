import gleam/float
import gleam/int
import gleam/io
import gleam/iterator
import gleam/result
import gleam/string

pub type Currency {
  Dollar
  Euro
  Won
}

fn currency_to_string(cur: Currency) -> String {
  case cur {
    Dollar -> "$"
    Euro -> "€"
    Won -> "₩"
  }
}

pub type TranslationSource =
  #(Currency, Float)

pub type RawAmount =
  String

fn calculate(src: TranslationSource, trgt_currency: Currency) -> Float {
  // hard coded
  let #(src_currency, src_amount) = src
  case src_currency {
    Dollar ->
      case trgt_currency {
        Dollar -> src_amount
        Euro -> src_amount *. 0.94
        Won -> src_amount *. 1390.0
      }
    Euro ->
      case trgt_currency {
        Dollar -> src_amount *. 1.07
        Euro -> src_amount
        Won -> src_amount *. 1487.5
      }
    Won ->
      case trgt_currency {
        Dollar -> src_amount *. 0.00072
        Euro -> src_amount *. 0.00067
        Won -> src_amount
      }
  }
}

fn translate(input: String) -> TranslationSource {
  case input |> string.replace(",", "") |> string.replace(" ", "") {
    "$" <> amount -> {
      case float.parse(amount) {
        Error(_e) ->
          case int.parse(amount) {
            Error(_e) -> panic
            Ok(n) -> #(Dollar, int.to_float(n))
          }
        Ok(n) -> #(Dollar, n)
      }
    }
    "₩" <> amount -> {
      case float.parse(amount) {
        Error(_e) ->
          case int.parse(amount) {
            Error(_e) -> panic
            Ok(n) -> #(Won, int.to_float(n))
          }
        Ok(n) -> #(Won, n)
      }
    }
    "euro" <> amount | "€" <> amount -> {
      case float.parse(amount) {
        Error(_e) ->
          case int.parse(amount) {
            Error(_e) -> panic
            Ok(n) -> #(Euro, int.to_float(n))
          }
        Ok(n) -> #(Euro, n)
      }
    }
    _ -> #(Euro, 1.0)
  }
}

pub fn main() {
  let input = "€ 1800.0"
  let target = Dollar
  let res =
    translate(input)
    |> calculate(target)
  io.debug(float.to_string(res) <> " " <> currency_to_string(target))
}
