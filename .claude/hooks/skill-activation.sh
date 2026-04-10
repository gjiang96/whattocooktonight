#!/bin/bash
# Auto-activates skills based on file context in the current prompt.
# Runs on every UserPromptSubmit event.

INPUT=$(cat)

if ! command -v jq &> /dev/null; then
  exit 0
fi

PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# Detect Rails/Ruby context
# Triggers on: .rb, .erb, Gemfile, routes, migration, controller, model mentions
RAILS_PATTERN='(\.rb|\.erb|Gemfile|gemspec|rails|rake|rspec|activerecord|migration|controller|serializer|use_case|domain|repository|sidekiq|rspec)'

# Detect React Native context
# Triggers on: .tsx, .ts, .jsx, expo, react-native mentions
RN_PATTERN='(\.tsx|\.ts|\.jsx|\.js|react.native|expo|component|screen|hook|navigation|stylesheet)'

RAILS_MATCH=false
RN_MATCH=false

if echo "$PROMPT" | grep -qiE "$RAILS_PATTERN"; then
  RAILS_MATCH=true
fi

if echo "$PROMPT" | grep -qiE "$RN_PATTERN"; then
  RN_MATCH=true
fi

# Also check recently mentioned file paths in the prompt
if echo "$PROMPT" | grep -qE '\.(rb|erb)$|app/(models|controllers|domain|use_cases|infrastructure|workers|serializers)/'; then
  RAILS_MATCH=true
fi

if echo "$PROMPT" | grep -qE '\.(tsx|ts|jsx)$|src/(screens|components|hooks|services)/'; then
  RN_MATCH=true
fi

# Output instructions for matched contexts
if [ "$RAILS_MATCH" = true ] && [ "$RN_MATCH" = true ]; then
  echo "INSTRUCTION: This task involves both Rails and React Native code. Apply the ruby, rails-best-practices, react-native, and react-native-performance skills."
elif [ "$RAILS_MATCH" = true ]; then
  echo "INSTRUCTION: This task involves Rails/Ruby code. Apply the ruby and rails-best-practices skills."
elif [ "$RN_MATCH" = true ]; then
  echo "INSTRUCTION: This task involves React Native code. Apply the react-native and react-native-performance skills."
fi
