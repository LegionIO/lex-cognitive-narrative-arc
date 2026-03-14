# lex-cognitive-narrative-arc

Narrative arc tracking for LegionIO cognitive agents. Models ongoing situations as story arcs with beats that drive tension through building, peak, resolving, and complete phases. Dramatic score synthesizes tension, event count, and intensity.

## What It Does

- Eight beat types: exposition, rising_action, complication, crisis, climax, falling_action, resolution, denouement
- Tension adjusts automatically per beat type (crisis/climax raise; resolution/denouement lower)
- Four arc phases: building → peak (tension >= 0.8) → resolving (tension <= 0.2) → complete
- Each beat has intensity (0.0–1.0) and emotional_charge (-1.0 to 1.0)
- Dramatic score: composite of tension (40%), beat count ratio (30%), average intensity (30%)
- Track active, completed, and most-dramatic arcs

## Usage

```ruby
# Create an arc
result = runner.create_arc(title: 'deployment_incident', domain: :operations, genre: :crisis)
arc_id = result[:arc][:id]

# Add beats
runner.add_beat(arc_id: arc_id, beat_type: :rising_action,
                 content: 'error rate climbing', intensity: 0.6)
runner.add_beat(arc_id: arc_id, beat_type: :crisis,
                 content: 'service unavailable', intensity: 0.9)
# => { success: true, arc: { tension: 0.5, phase: :building, ... } }

runner.add_beat(arc_id: arc_id, beat_type: :climax,
                 content: 'root cause identified', intensity: 1.0)
# tension reaches peak phase

runner.add_beat(arc_id: arc_id, beat_type: :resolution,
                 content: 'hotfix deployed', intensity: 0.7)

# Check most dramatic
runner.most_dramatic_arc
# => { success: true, arc: { title: 'deployment_incident', dramatic_score: 0.73, ... } }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
