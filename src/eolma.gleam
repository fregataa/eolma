import gleam/float
import gleam/int
import gleam/io
import gleam/string

pub type Currency {
  Dollar
  Euro
  Won
}

fn get_exchange_rate(from: Currency, to: Currency) -> Float {
  // hard coded
  case from {
    Dollar -> {
      case to {
        Dollar -> 1.0
        Euro -> 0.94
        Won -> 1391.0
      }
    }
    Euro -> {
      case to {
        Dollar -> 1.07
        Euro -> 1.0
        Won -> 1487.47
      }
    }
    Won -> {
      case to {
        Dollar -> 0.00072
        Euro -> 0.00067
        Won -> 1.0
      }
    }
  }
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

fn calculate(src: TranslationSource, trgt_currency: Currency) -> Float {
  let #(src_currency, src_amount) = src
  get_exchange_rate(src_currency, trgt_currency) *. src_amount
}

fn translate(input: String) -> TranslationSource {
  case
    input
    |> string.lowercase
    |> string.replace(",", "")
    |> string.replace(" ", "")
  {
    "dollar" <> amount | "$" <> amount -> {
      case float.parse(amount) {
        Error(_e) ->
          case int.parse(amount) {
            Error(_e) -> panic
            Ok(n) -> #(Dollar, int.to_float(n))
          }
        Ok(n) -> #(Dollar, n)
      }
    }
    "won" <> amount | "₩" <> amount -> {
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
    _ -> panic
  }
}

pub fn main() {
  let input = "€ 1800.0"
  let target = Won
  let res =
    translate(input)
    |> calculate(target)
  io.debug(float.to_string(res) <> " " <> currency_to_string(target))
}
