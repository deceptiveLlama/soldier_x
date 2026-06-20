# Soldier X — Balance Framework & Talent Reference

> Source of truth for design intent + current per-rank numbers. Numbers are pulled from `declarations.opy` macros; cooldowns from `talents.js` (`talent_base_cooldowns`) and the cooldown-check sites in `talents.opy`. Update this file whenever a macro changes.

---

## Part 1 — Framework & Design Intents *(stable)*

### The Helix anchor
- **1 Helix = 120 damage, full value.** Most Helix hits ARE direct (you go in close and aim at feet).
- **Common currency:** 1 EHP ≈ 1 healing ≈ 1 damage.

### Power budget
- **Add-on talent @ R5 ≈ 1 Helix** of net value.
- **Replacement talent @ R5 ≈ 2 Helix** (half buys back what you lose, half is the real benefit).
- **Clean 2× slope:** R5 ≈ 2× R1 for add-on *effectiveness*. Does not apply to replacement talents (R1 must be a functional weapon) or to pricing downsides (a downside scales with the upside it prices, not 2×).

### Reliability adjustments
- Hard-to-execute (Railgun charge + self-slow) or situational (Dive Bomb needs height) → allow higher numbers.
- AoE rarely multi-hits in this mode → don't discount it much, but don't over-credit size as a downside either.
- Instant/guaranteed, zero-input effects → at or below baseline (high reliability pushes the number *down*).

### Constraints
- Balance for 4 players on the server (servers are rarely full). Most fights are still 1v1, but meaningful group fights can happen.
- Base HP **500** (Soldier 250 × 2 via `setMaxHealth` taking a %; `stats[HEALTH] = 200`).
- Fights last **5–10s** with **5–10s downtime** between → out-of-combat healing gets near-full uptime; value healing across the whole fight-cycle.

### Core principles
- **No cross-talent power amplification.** A talent must not be more effective just because it's combined with another *independent* talent. Intended synergies are only those routed through the dependency system (`requires_any_of` / `expand_mind`). Descriptions must not advertise cross-talent scaling.
- **% -of-own-output is intrinsic, not a violation** (e.g. Lifesteal scaling with your damage). A violation is a *separate larger value keyed to another talent that overshoots parity*.

### Per-talent design intents (the deliberate exceptions)
- **Gigachad** — intentional flagship, knowingly ~2–2.5× over budget (1000 HP @ R5), paid for by +35% size and −25% speed.
- **Lifesteal** — heals **in combat only**; allowed to be the best *sustained* in-combat heal because it has zero out-of-combat value.
- **Soul Harvest** — intentionally hot; it's mostly a *win-reward* (you only collect the orb after winning), so it recovers you for the next fight rather than winning the current one. Although rare, finding stray orbs mid-fight is possible, and can turn a fight around.
- **Health Regen** — a soft always-on blanket (heals in AND out of combat) that just does its job over a long time.
- **Health Potions** — high burst potential: Wait a long time to bank 3 and dump them for a big spike, or use them more sparingly.

---

## Part 2 — Talents *(subject to change)*

Each entry: current per-rank values + cooldown, traits, and the reasoning behind the numbers. Reasoning marked *(not formally reviewed)* means the values are pre-existing and haven't yet been checked against the framework.

### Railgun
- **Values:** body 100 → 200, headshot 150 → 300. Cooldown 6s.
- **Traits:** Replaces secondary fire. Hitscan, no falloff, headshots ×1.5, charge-up + self-slow.
- **Reasoning:** Replacement weapon → ~2 Helix @ R5. Hitscan + no-falloff + crit lift the effective floor, so R1 body 100 ≈ 1 Helix despite the low raw number — which is why the slope is steeper than a normal add-on. The charge + self-slow is the reliability cost that lets the numbers run high.

### Fireball
- **Values:** direct 40 → 80, + DoT 40 → 80 over 5s (total 80 → 160). Cooldown 20s.
- **Traits:** Projectile (speed 15, radius 1.75, explosion 4m). Self-damage (16.7 → 33 direct + self-DoT). AoE.
- **Reasoning:** Add-on on a 20s CD → fires ~every other fight, so 160 burst amortizes to ~0.8–1 Helix. Dodgeable projectile + travel time + self-damage justify sitting right at budget. Clean 2× slope.

### Dive Bomb
- **Values:** 75 → 150, doubled to 150 → 300 at full 1s airborne. Cooldown 20s.
- **Traits:** Needs ≥3.5m height. Knockback. Damage scales with airtime up to 1s.
- **Reasoning:** Situational + heavily telegraphed (committed airborne, target can juke) → framework allows higher numbers. 300 charged is intentional high-risk burst. Clean 2× slope.

### Ignite
- **Values:** DoT 40 → 80 total over 3s (off Helix); 50 → 100 off Railgun. No cooldown.
- **Traits:** % of secondary-fire damage as fire DoT. Rides every secondary hit.
- **Reasoning:** Add-on rider ≈ ~1 Helix/fight at typical Helix cadence. The higher Railgun value normalizes for Railgun's slower (charged) fire rate so total fire-DoT per fight stays on par — normalization, not amplification (100/80 = 1.25× ≈ Railgun firing ~80% as often). Clean 2× slope.

### Burning Soul
- **Values:** 3.0 → 6.0 per 0.25s tick (12 → 24 DPS). No cooldown.
- **Traits:** 8m aura, damages nearby visible players while NOT sprinting. Orb punish: 75 + orb_rank×25 to enemies who eat your orb within 4s. Zero-input.
- **Reasoning:** Value swings ~0.5–1.7 Helix purely on positioning (sprint/LOS/8m gate it). Slope steepened to a clean 2× (was 1.67×), holding R5 at 24 DPS — the high end of ~1 Helix given realistic uptime, acceptable because the not-sprinting cost is real in a mobility mode.

### Poisonous Dagger
- **Values:** 100 → 200, lands after a 5s delay. Cooldown 20s.
- **Traits:** Stealth-melee applies a delayed poison. A debuff — cleansable (Bandage removes it, visual included).
- **Reasoning:** 200 delayed burst gated behind Stealth + a sneak-melee + 5s payoff → ~1 Helix, arguably conservative for the setup. Its real strength is the **risk-free application**, not the damage — that's the lever to tune (redesign pending), not the number.

### Grim Reaper
- **Values:** cast time 2.0 → 1.0s, flight speed 15.6 → 30. No cooldown yet.
- **Traits:** See low-HP players (≤25%). Cast to project yourself to your target (4m radius). The lunge deals no damage.
- **Reasoning:** A finisher/mobility tool, not a damage-budget talent. Ranks buy cast/flight speed to reward investment. Cooldown intentionally absent for now (would only be set on a completed lunge if added).

### Lifesteal Ammo
- **Values:** 15% → 30% of damage dealt, healed back. No cooldown.
- **Traits:** Heals off primary + secondary damage. In-combat only (must be landing shots).
- **Reasoning:** R5 30% ≈ ~1.25 Helix in a 500-damage fight — the ~0.25 Helix premium over pure-sustain healers is paid for by **zero out-of-combat value**. Best *sustained* in-combat heal. Clean 2× slope (15 → 30).

### Soul Harvest
- **Values:** 125 → 250 healing per orb. No cooldown.
- **Traits:** Instant heal on XP-orb pickup. Pairs with mobility.
- **Reasoning:** Mostly a **win-reward** (you collect the orb after winning), so it recovers you for the next fight rather than winning the current one → allowed to run hot at ~2 Helix/orb. Clean 2× slope.

### Health Regen
- **Values:** 4.5 → 9.0 /s, continuous. No cooldown.
- **Traits:** Always-on, in AND out of combat. Zero-input.
- **Reasoning:** Soft blanket — ~9/s over a 14s fight-cycle ≈ ~1 Helix. Slope fixed to a clean 2× (4.5 → 9.0). Always-on is intended; no out-of-combat gate.

### Health Potions
- **Values:** 200 → 400 total across 3 potions. Refill 15s/potion (−1s per Alchemist rank).
- **Traits:** Each potion heals over 2s; the 3 HoTs stack. Banked dump = ~400 over ~3s, heals under fire (no damage-interrupt).
- **Reasoning:** ~1 Helix amortized over the refill, but the **burst** is the real strength — a banked dump is clutchier than Bandage's interrupt-locked 400. Clean 2× slope (200 → 400).

### Bandage
- **Values:** 200 → 400 over 10s. Cooldown 30s.
- **Traits:** Full cleanse (poison, burning, frozen, cryo slow, all DoTs). Interrupted by damage; reduces move speed; can't remove stuns.
- **Reasoning:** Big out-of-combat heal + cleanse utility. ~1.2 Helix once the interrupt-on-damage and slow are priced in. Clean 2× slope.

### Pyromaniac
- **Values:** instant 40 → 80, + HoT 40 → 80 over 5s. No cooldown.
- **Traits:** Heals you when you stand near your Fireball explosion.
- **Reasoning:** ~0.8 Helix, gated by Fireball uptime + standing in the blast. Clean 2× slope.

### Bloodthirst
- **Values:** 25.2% → 50% of damage dealt during Berserker. No cooldown (tied to Berserker's 45s).
- **Traits:** Heals after Berserker; can overheal (decays). Cancel Berserker early to bank more healing.
- **Reasoning:** Spiky defensive burst rather than sustain — the 45s Berserker CD and overheal-with-decay keep it from being raw throughput.

### Gigachad
- **Values:** +100 HP/rank (600 → 1000 total), size +7%/rank (1.07 → 1.35×), speed −5%/rank (95% → 75%). No cooldown.
- **Traits:** Passive. Crit heal-back: full headshot damage lands first, then heals back a rank-scaled portion.
- **Reasoning:** Intentional flagship, knowingly ~2–2.5× over budget, paid for by the size and speed penalties. Heal-back is headshot-scoped so it doesn't blanket-reduce all damage.

### Cybernetics
- **Values:** shields 75 → 150. No cooldown.
- **Traits:** Permanent shields, regen when out of combat, can't be healed by abilities.
- **Reasoning:** Flat EHP add-on; 75 → 150 shields ≈ within ~1 Helix of EHP. *(Not formally reviewed.)*

### Ignore Pain
- **Values:** resist 40% → 66.7% (damage received 60% → 33.3%). No cooldown.
- **Traits:** Active only while casting, reloading, sprinting, or stunned.
- **Reasoning:** Value rides entirely on the uptime of those states. *(Not formally reviewed.)*

### Berserker
- **Values:** duration 5 → 10s. Cooldown 45s.
- **Traits:** +25% damage, +10% damage taken. The anchor for Bloodthirst.
- **Reasoning:** Offensive cooldown; mechanic is set but the numbers aren't budgeted as a single value. *(Not formally reviewed.)*

### Purity Field
- **Values:** duration 5 → 10s, healing received 150% → 250%. Cooldown 45s.
- **Traits:** Mobile near-invuln bubble (0.001 dmg taken), increased healing, full mobility (slowed), no damage abilities.
- **Reasoning:** Defensive ult; mechanic finalized after the redesign, numbers not budgeted as a single value. *(Not formally reviewed.)*

### Cryogenics
- **Values:** slow 60% → 100%, duration 2.2 → 3.0s. Cooldown 6s.
- **Traits:** Secondary fire slows + blocks sprint.
- **Reasoning:** Slow made proportional (speed × (0.5 − rank×0.1)) so it never goes negative on reduced-base players. Magnitude itself not formally budgeted. *(Slow formula fixed; magnitude not reviewed.)*

### Shadowstep
- **Values:** cooldown 20s → 10s (22.5 − rank×2.5). 0.5s invuln/invis.
- **Traits:** Leap in any direction. XP-orb pickups reset the cooldown.
- **Reasoning:** Escape/mobility; ranks buy cooldown. *(Not formally reviewed.)*

### Stealth
- **Values:** stun 1.0 → 1.8s (+ stealth duration scaling). Cooldown 10s.
- **Traits:** Crouch out of combat to enter stealth; melee from stealth stuns. Broken by taking damage or using damage abilities.
- **Reasoning:** Repositioning + setup for the stealth-melee stun (and Poisonous Dagger). *(Not formally reviewed.)*

### Jetpack
- **Values:** +fuel efficiency per rank. No cooldown.
- **Traits:** Hold while airborne to fly.
- **Reasoning:** Vertical mobility. *(Not formally reviewed.)*

### Overclock
- **Values:** reduces Railgun cooldown per rank. No cooldown.
- **Traits:** Passive.
- **Reasoning:** Cooldown-reduction modifier. *(Exact reduction not pinned in this doc.)*

### Alchemist
- **Values:** −1s potion refill per rank; orb proc chance 33% + (rank−1)×8.25% to gain a potion. No cooldown.
- **Traits:** Passive.
- **Reasoning:** Throughput/uptime modifier for Health Potions. *(Not formally reviewed.)*

---

## Disabled / unimplemented
- **Juggernaut** — 150 → 250, 20s CD. Sprint, stun+grab on player hit, AoE on wall hit. Commented out, not in the pool.
- **Poison Vials** — stacking DoT, 15s CD. Commented out.
- **Javelin** — enum only, no implementation.
- **Bombardment / Gunslinger / Adrenaline Rush** — commented out.

---

## Open / pending
- **Weapon-choice redesign** — make Helix / Railgun / Fireball mutually exclusive (disable Helix as the free baseline). Would retire the "replacement = 2 Helix" rule. Needs: early-weapon-access guarantee, Fireball CD rework. Not committed.
- **Poisonous Dagger** — risk-free application is the problem, not the damage. Application redesign pending.
- **Uncompiled this session:** Burning Soul & Health Regen slopes, Lifesteal 30%, Soul Harvest 250, Health Potions 400 — run through the OverPy compiler when playtesting.
