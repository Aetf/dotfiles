AddPackage claude-code # An agentic coding tool that lives in your terminal

# Fixed Claude Code settings live in the managed drop-in directory rather than
# in the user's settings.json, because Claude Code itself writes that file
# (/model, /effort, /config) and a yadm-rendered copy would be overwritten by
# every yadm invocation. Managed keys cannot be overridden from a session, so
# only keys that are never changed interactively belong here; hosts add their
# own drop-ins next to these.
CopyFile /etc/claude-code/managed-settings.d/10-memory.json
