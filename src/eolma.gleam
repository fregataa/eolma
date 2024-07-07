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

pub type Language {
  Korean
  English
  Nil
}

fn translate_numeral_to_float(src: String) -> Float {
  case src {
    "조" -> 1_000_000_000_000.0
    "억" -> 100_000_000.0
    "만" -> 10_000.0
    "trillion" -> 1_000_000_000_000.0
    "billion" -> 1_000_000_000.0
    "million" -> 1_000_000.0
    "thousand" -> 1000.0
    _ -> panic
  }
}

fn largest_korean_numeral_unit(num: Float) -> String {
  case num /. 1_000_000_000_000.0 >=. 1.0 {
    True -> float.to_string(num /. 1_000_000_000_000.0) <> "조"
    False ->
      case num /. 100_000_000.0 >=. 1.0 {
        True -> float.to_string(num /. 100_000_000.0) <> "억"
        False ->
          case num /. 10_000.0 >=. 1.0 {
            True -> float.to_string(num /. 10_000.0) <> "만"
            False -> float.to_string(num)
          }
      }
  }
}

fn largest_english_numeral_unit(num: Float) -> String {
  case num /. 1_000_000_000_000.0 >=. 1.0 {
    True -> float.to_string(num /. 1_000_000_000_000.0) <> "trillion"
    False ->
      case num /. 1_000_000_000.0 >=. 1.0 {
        True -> float.to_string(num /. 1_000_000_000.0) <> "billion"
        False ->
          case num /. 1_000_000.0 >=. 1.0 {
            True -> float.to_string(num /. 1_000_000.0) <> "million"
            False ->
              case num /. 1000.0 >=. 1.0 {
                True -> float.to_string(num /. 1000.0) <> "thousand"
                False -> float.to_string(num)
              }
          }
      }
  }
}

fn translate_float_to_numeral(src: Float, trgt_lang: Language) -> String {
  case trgt_lang {
    Korean -> largest_korean_numeral_unit(src)
    English -> largest_english_numeral_unit(src)
    Nil -> float.to_string(src)
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
  let input = "won 180000000.0"
  let target = Dollar
  let target_lang = Korean
  let res =
    translate(input)
    |> calculate(target)
    |> translate_float_to_numeral(target_lang)
  io.debug(res <> " " <> currency_to_string(target))
}
