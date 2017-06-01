import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Http exposing (..)
import Json.Decode exposing (..)
import Task
import Time exposing (Time, second)
import String exposing (left, dropLeft, toUpper)


main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL


type alias Model =
  { name : String
  , email : String
  , reply : String
  , replyTime : Int
  , replyError : String
  }


init : (Model, Cmd Msg)
init = 
  (Model "" "" "" 0 "", Cmd.none)


-- UPDATE


type Msg
    = Name String
    | Email String
    | Submit
    | PostFail Http.Error
    | PostSucceed (String, String)
    | Tick Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Name name ->
      ({ model | name = capitalize name }, Cmd.none)

    Email email ->
      ({ model | email = email }, Cmd.none)

    Submit ->
      (model, submit model)

    PostFail _ ->
      (model, Cmd.none)

    PostSucceed (typeString, textString) ->
      case typeString of
        "message" ->
          ({ model |
               reply = textString, 
               replyTime = 10,
               replyError = ""}, Cmd.none)

        "error" ->
          ({ model |
               reply = "", 
               replyTime = -1,
               replyError = textString}, Cmd.none)
        _ -> 
          (model, Cmd.none)

    Tick newTime ->
      ({ model |
          replyTime = (model.replyTime - 1)}, Cmd.none)

capitalize : String -> String
capitalize word = 
  toUpper (left 1 word) ++ dropLeft 1 word

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every second Tick


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ div [ class "header-img"] [ img [src "Hitboxlogo.png"] []]
    , div [ class "prompt"] [text "Enter your name and email to receive updates on Hitbox"]
    , div [ class "inputs"] [ input [ type' "text", placeholder "Full Name", onInput Name ] [], input [ type' "email", placeholder "Email", onInput Email ] [] ]
    , div [ class "submit-button"] [ button [ onClick Submit ] [ text "Submit"]]
    , viewReply model
    ]

viewReply : Model -> Html Msg
viewReply model =
  if model.replyError /= "" then
    div [ style [("opacity", "1")], class "error-message"] [ text model.replyError]
  else if model.replyTime > 0 then
    div [ style [("opacity", "1")], class "text-message"] [ text model.reply]
  else 
    div [ style [("opacity", "0")], class "text-message"] [ text model.reply]


-- HTTP


submit : Model -> Cmd Msg
submit model = 
  let 
    request =
        { verb = "POST"
        , headers = [( "Content-Type", "application/x-www-form-urlencoded" )]
        , url = "submit_email.php"
        , body = Http.string ("name=" ++ model.name ++ "&email=" ++ model.email)
        }
  in 
    Task.perform PostFail PostSucceed (Http.fromJson decoder (Http.send Http.defaultSettings request))

decoder : Decoder (String, String)
decoder = 
  object2 (,) ("type" := Json.Decode.string ) ("text" := Json.Decode.string)