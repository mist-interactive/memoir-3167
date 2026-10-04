from __future__ import annotations

import datetime as dt
import html
import subprocess
from collections import defaultdict
from pathlib import Path


DAYS = 365
CELL = 12
GAP = 3
LABEL_WIDTH = 150
TOP_PADDING = 45
BOTTOM_PADDING = 35

OUTPUT = Path("assets/contributions.svg")


def get_commits():
    result = subprocess.run(
        [
            "git",
            "log",
            "--all",
            "--date=format:%Y-%m-%d",
            "--format=%aN%x1f%aE%x1f%ad",
        ],
        capture_output=True,
        text=True,
        check=True,
    )

    commits = []

    for line in result.stdout.splitlines():
        try:
            name, email, date = line.split("\x1f")
            commits.append((name.strip(), email.strip().lower(), date))
        except ValueError:
            continue

    return commits


def main():
    today = dt.date.today()
    start = today - dt.timedelta(days=DAYS - 1)

    # contributor -> date -> commits
    data = defaultdict(lambda: defaultdict(int))

    for name, email, date_string in get_commits():
        try:
            date = dt.date.fromisoformat(date_string)
        except ValueError:
            continue

        if start <= date <= today:
            # Email is used internally to distinguish authors with
            # the same display name. It is never written to the SVG.
            key = (name, email)
            data[key][date] += 1

    contributors = []

    for (name, email), dates in data.items():
        total = sum(dates.values())
        contributors.append((name, email, dates, total))

    contributors.sort(key=lambda x: (-x[3], x[0].lower()))

    # At least one row so the SVG remains valid for an empty repo.
    if not contributors:
        contributors = [("No contributions", "", {}, 0)]

    # Arrange dates into weeks, Sunday -> Saturday.
    first = start - dt.timedelta(days=(start.weekday() + 1) % 7)
    last = today + dt.timedelta(days=(6 - ((today.weekday() + 1) % 7)))
    days = (last - first).days + 1
    weeks = days // 7

    graph_width = weeks * (CELL + GAP)
    width = LABEL_WIDTH + graph_width + 20
    row_height = 30
    height = TOP_PADDING + len(contributors) * row_height + BOTTOM_PADDING

    def level(value, max_value):
        if value == 0:
            return 0

        # Relative intensity per contributor.
        ratio = value / max_value if max_value else 0

        if ratio <= 0.25:
            return 1
        if ratio <= 0.50:
            return 2
        if ratio <= 0.75:
            return 3
        return 4

    svg = [
        f'<svg xmlns="http://www.w3.org/2000/svg" '
        f'width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}">',
        '<rect width="100%" height="100%" fill="#ffffff" rx="8"/>',
        '<style>',
        '.title{font:600 18px -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;fill:#24292f}',
        '.name{font:500 12px -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;fill:#24292f}',
        '.count{font:11px -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;fill:#57606a}',
        '</style>',
        '<text x="16" y="27" class="title">Repository contributions — last year</text>',
    ]

    colors = {
        0: "#ebedf0",
        1: "#9be9a8",
        2: "#40c463",
        3: "#30a14e",
        4: "#216e39",
    }

    for row, (name, email, dates, total) in enumerate(contributors):
        y = TOP_PADDING + row * row_height

        display_name = html.escape(name[:24])
        svg.append(
            f'<text x="16" y="{y + 11}" class="name">{display_name}</text>'
        )
        svg.append(
            f'<text x="16" y="{y + 24}" class="count">{total} commits</text>'
        )

        max_value = max(dates.values(), default=1)

        for week in range(weeks):
            for weekday in range(7):
                date = first + dt.timedelta(days=week * 7 + weekday)

                if date < start or date > today:
                    continue

                value = dates.get(date, 0)
                x = LABEL_WIDTH + week * (CELL + GAP)
                cell_y = y + weekday * 2

                # Make each contributor row compact: aggregate the
                # seven daily cells into a weekly strip.
                #
                # The actual daily graph is rendered below instead.
                _ = cell_y

        # Full 7-day heatmap, scaled vertically.
        day_cell = 4
        day_gap = 1

        for week in range(weeks):
            for weekday in range(7):
                date = first + dt.timedelta(days=week * 7 + weekday)

                if date < start or date > today:
                    continue

                value = dates.get(date, 0)
                x = LABEL_WIDTH + week * (CELL + GAP)
                cell_y = y + weekday * (day_cell + day_gap)

                title = (
                    f"{html.escape(name)} — "
                    f"{date.isoformat()} — {value} commit"
                    f"{'s' if value != 1 else ''}"
                )

                svg.append(
                    f'<rect x="{x}" y="{cell_y}" '
                    f'width="{CELL}" height="{day_cell}" '
                    f'rx="1.5" fill="{colors[level(value, max_value)]}">'
                    f"<title>{title}</title>"
                    f"</rect>"
                )

    svg.append(
        f'<text x="16" y="{height - 13}" class="count">'
        f"Total contributors: {len(contributors)}"
        f"</text>"
    )

    svg.append("</svg>")

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text("\n".join(svg), encoding="utf-8")

    print(
        f"Generated {OUTPUT} "
        f"for {len(contributors)} contributors."
    )


if __name__ == "__main__":
    main()
