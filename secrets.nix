let
  nova = "age1w9hrgxmtk30ysfqa480q0v5k9490wlq4p7yzcjg2w0qk44useqeqwpdyvy";
  orion = "age1ahk9g5w9nu03tr25y2ql227ee20np75hzrkjgaj9ylfv0fdz7fcsvww5zc";
in
{
  "secrets/orion-romain-password.age".publicKeys = [ nova orion ];
}
