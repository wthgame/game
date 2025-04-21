# Damager

Damagers are a Mechanic that damages the player while they're touching it. It is
most alike to EToH's Killbricks.

To encourage damagers to be used as an actual hazard, damagers deal *consistent*
damage every 0.5 seconds.

Damagers have some preset `Damage` values:

- `Normal` damage of 10
- `Heavy` damage of 20
- `Super` damage of 40
- `Lethal` damage that kills the player

The `Damage` attribute can also be set to a number for custom damage values.
Note that this number must be positive.

## Attributes

### Enabled `: boolean`

Toggles if this Damager should deal damage.

### Damage `: number | "Normal" | "Heavy" | "Super" | "Lethal"`

The amount of damage this Damager deals, given:

- `Normal` damage of 10
- `Heavy` damage of 20
- `Super` damage of 40
- `Lethal` damage that kills the player
- Or any positive number to be dealt as damage
