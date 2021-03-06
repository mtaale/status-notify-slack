#!/bin/sh

status_url=$STATUS_URL
status_timeout=$STATUS_TIMEOUT
notify_timeout=$NOTIFY_TIMEOUT
channel=$SLACK_CHANNEL
username=$SLACK_USERNAME
username_ok=$SLACK_USERNAME_OK
text=$SLACK_NOTIFICATION_TEXT
text_ok=$SLACK_NOTIFICATION_TEXT_OK
icon=$SLACK_NOTIFICATION_ICON
icon_ok=$SLACK_NOTIFICATION_ICON_OK
webhook_url=$SLACK_NOTIFICATION_WEBHOOK_URL
curl_max_timeout=$CURL_MAX_TIMEOUT
max_fails_allowed=$MAX_FAILS_ALLOWED
fail_count=0;

while :
do
  status=`curl -m $curl_max_timeout -s -o /dev/null -w "%{http_code}" $status_url`
  if [ $status -eq 200 ]; then
    echo "Application works."
    if [ $fail_count -ge $max_fails_allowed ]; then
      curl -X POST --data-urlencode "payload={\"channel\": \"$channel\", \"username\": \"$username_ok\", \"text\": \"$text_ok\", \"icon_emoji\": \"$icon_ok\"}" $webhook_url
    fi
    fail_count=0
    sleep $status_timeout
  else
    fail_count=$((fail_count+1))
    echo "fail count: $fail_count"
    if [ $fail_count -ge $max_fails_allowed ]; then
      echo "Application is not working."
      curl -X POST --data-urlencode "payload={\"channel\": \"$channel\", \"username\": \"$username\", \"text\": \"$text\", \"icon_emoji\": \"$icon\"}" $webhook_url
    fi
    sleep $notify_timeout
  fi
done
