# lex-cognitive-narrative-arc

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Narrative arc tracking engine for cognitive processing. Models ongoing cognitive situations as narrative arcs with beats that drive tension through phases. Beat events (exposition, rising_action, complication, crisis, climax, falling_action, resolution, denouement) each carry intensity and emotional_charge and adjust the arc's tension level. Phases (building, peak, resolving, complete) transition automatically based on tension thresholds. A dramatic score synthesizes tension, beat count, and average intensity.

## Gem Info

- **Gem name**: `lex-cognitive-narrative-arc`
- **Module**: `Legion::Extensions::CognitiveNarrativeArc`
- **Version**: `0.1.0`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_narrative_arc/
  version.rb
  client.rb
  helpers/
    constants.rb
    arc.rb
    beat_event.rb
  runners/
    narrative.rb
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `MAX_ARCS` | `100` | Per-engine arc capacity |
| `MAX_BEATS_PER_ARC` | `50` | Max beats per arc |
| `DEFAULT_TENSION` | `0.3` | Starting tension for new arcs |
| `TENSION_RISE` | `0.1` | Tension increase for escalating beats |
| `TENSION_FALL` | `0.08` | Tension decrease for resolving beats |
| `CLIMAX_THRESHOLD` | `0.8` | Tension above which arc enters peak phase |
| `RESOLUTION_THRESHOLD` | `0.2` | Tension below which arc enters resolved phase |
| `BEAT_TYPES` | `%i[exposition rising_action complication crisis climax falling_action resolution denouement]` | Valid beat types |
| `ARC_PHASES` | `%i[building peak resolving complete]` | Arc lifecycle phases |
| `TENSION_LABELS` | range hash | From `:calm` to `:explosive` |
| `DRAMA_LABELS` | range hash | From `:mundane` to `:epic` |
| `PHASE_LABELS` | hash | Human-readable phase names |

## Helpers

### `Helpers::BeatEvent`
Immutable (frozen) record of a single narrative beat. Has `id`, `beat_type`, `content`, `intensity` (0.0–1.0), `emotional_charge` (-1.0 to 1.0), and `occurred_at`.

- `climactic?` — `beat_type == :climax`
- `resolving?` — `beat_type` is `:resolution` or `:denouement`
- `emotional_charge` — pre-computed from beat type: crisis/climax are negative, resolution/denouement are positive

### `Helpers::Arc`
Active narrative arc. Has `id`, `title`, `domain`, `genre`, `tension`, `phase`, `beats` (array of `BeatEvent`), and `created_at`.

- `add_beat!(beat_type:, content:, intensity:)` — creates `BeatEvent`, adjusts tension (escalating beats raise tension, resolving beats lower it), appends to beats array
- `advance_phase!` — checks tension vs thresholds and transitions phase
- `tension_rise!(amount)` — direct tension increase
- `tension_fall!(amount)` — direct tension decrease
- `climaxed?` — phase is `:peak` or later
- `resolved?` — phase is `:resolving` or `:complete`
- `complete?` — phase is `:complete`
- `dramatic_score` — composite: `tension * 0.4 + (beat_count / MAX_BEATS) * 0.3 + avg_intensity * 0.3`

## Runners

Module: `Runners::Narrative`

| Runner Method | Description |
|---|---|
| `create_arc(title:, domain:, genre:)` | Start a new narrative arc |
| `add_beat(arc_id:, beat_type:, content:, intensity:)` | Add a beat to an arc |
| `get_arc(arc_id:)` | Retrieve arc details |
| `active_arcs` | All arcs not yet complete |
| `completed_arcs` | All resolved/complete arcs |
| `most_dramatic_arc` | Arc with highest dramatic score |
| `arc_report` | Aggregate stats across all arcs |

All runners return `{success: true/false, ...}` hashes.

## Integration Points

- `lex-emotion`: beat emotional_charge directly feeds into `lex-emotion` valence evaluation
- `lex-tick` `action_selection`: high-tension arcs (peak phase) should trigger cautious behavior; resolved arcs can close open actions
- `lex-conflict`: rising_action/complication/crisis beats parallel conflict escalation in `lex-conflict`
- `lex-memory`: arcs serve as episodic containers — complete arcs can be consolidated as episodic memory traces

## Development Notes

- `Client` instantiates `@narrative_engine = Helpers::NarrativeEngine.new`
- `add_beat!` drives both the events log and phase transitions atomically
- `TENSION_RISE` is applied for: `rising_action`, `complication`, `crisis`, `climax` beats
- `TENSION_FALL` is applied for: `falling_action`, `resolution`, `denouement` beats
- `exposition` beats are neutral (no tension change)
- `dramatic_score` normalizes beat_count to `MAX_BEATS_PER_ARC` so all three components are [0.0, 1.0]
