function fallback_prompt
  # Just calculate these once, to save a few cycles when displaying the prompt
  if not set -q __fish_prompt_normal
    set -g __fish_prompt_normal (set_color normal)
  end
  
  if not set -q __aetf_prompt_symbol
    switch $USER
      case root toor
        set -g __aetf_prompt_symbol '#'
    case '*'
      set -g __aetf_prompt_symbol '$'
    end
  end
  
  echo -n -s '['
  set_color green
  echo -n -s "$USER" ' '
  set_color blue
  echo -n -s (prompt_pwd)
  set_color normal
  echo -n -s ']'
  set_color blue
  echo -n -s "$__aetf_prompt_symbol" ' '
  set_color normal
end
