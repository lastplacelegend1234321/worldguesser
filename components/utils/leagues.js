export const leagues = {
  'explorer': {
    min: 0,
    max: 1999,
    name: 'Traveller',
    emoji: '🛤',
    color: '#808080', // grey
    light: '#d3d3d3' // light grey
  },
  'trekker': {
    min: 2000,
    max: 4999,
    name: 'Explorer',
    emoji: '🧭',
    color: '#cd7f32' // bronze
  },
  'voyager': {
    min: 5000,
    max: 7999,
    name: 'Pilot',
    emoji: '✈️',
    color: '#ffd700' // gold
  },
  'nomad': {
    min: 8000,
    max: 20000,
    name: 'Conqueror',
    emoji: '🌎',
    color: '#b9f2ff' // diamond
  },
}


export const getLeague = (elo) => {
  for (const league in leagues) {
    if (elo >= leagues[league].min && elo <= leagues[league].max) {

      return leagues[league];
    }
  }
}

export const getLeagueRange = (name) => {
  const league = Object.values(leagues).find(league => league.name === name);
  return [league.min, league.max];
}