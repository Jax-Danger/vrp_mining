local cfg = {}

cfg.blips = {
  {name="Rock Quarry", id=527, size=0.85, color=2, coords={2942.82, 2785.14, 39.81}},
  {name="Smelt Ores", id=527, size=0.85, color=54, coords={1088.83, -1992.99, 30.97}}
}

cfg.rocks = {
  {2938.928, 2811.8457, 42.5892},
  {2926.2732, 2812.2129, 44.328},
  {2922.354, 2799.4331, 41.2956},
  {2926.3745, 2793.4912, 40.6304},
  {2934.7593, 2785.042, 39.552},
  {2938.0247, 2775.1118, 39.2296},
  {2940.5308, 2769.9067, 39.4667},
  {2947.8174, 2768.3159, 38.9375},
  {2951.3611, 2769.1807, 39.0334},
  {2956.4971, 2773.8616, 40.0127},
  {2964.0603, 2774.4851, 39.7477},
  {2969.0908, 2776.5581, 38.383}
}

cfg.smelting = {
  coords={1113.3628, -2005.5374, 35.4394},
  {
    input='iron_ore',
    inamount=3,
    output='iron_processed',
    outamount=1
  },
  {
    input='gold_ore',
    inamount=3,
    output='gold_processed',
    outamount=1
  },
}

cfg.useNPC = true
cfg.NPC = {
  model = 's_m_m_autoshop_01',
  coords = {2677.3484, 2791.0667, 40.5186},
  heading = 94.2064
}

return cfg
