---
---
# {{ page.title }}

{% if page.nickname %}**{{ page.nickname }}**{% endif %}

{{ page.description }}

## License Text

```
{{ content }}```

## Permissions

{% for permission in page.permissions -%}
- {{ permission }}
{% endfor %}

## Conditions

{% for condition in page.conditions -%}
- {{ condition }}
{% endfor %}

## Limitations

{% for limitation in page.limitations -%}
- {{ limitation }}
{% endfor %}

## How to Apply

{{ page.how }}
