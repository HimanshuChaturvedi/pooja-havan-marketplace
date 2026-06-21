const url = 'https://xzmekcjsjixtvknfbfkx.supabase.co/rest/v1';
const apikey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc';

async function run() {
  try {
    console.log('Fetching database OpenAPI schema...');
    const res = await fetch(`${url}/`, {
      headers: {
        'apikey': apikey,
        'Authorization': `Bearer ${apikey}`
      }
    });
    
    if (res.ok) {
      const data = await res.json();
      console.log('--- ALL TABLES IN DATABASE ---');
      console.log(Object.keys(data.paths).filter(path => path !== '/').map(path => path.substring(1)));
    } else {
      console.log('Failed to fetch:', res.status, res.statusText);
    }
  } catch (error) {
    console.error('Error running check:', error);
  }
}

run();
