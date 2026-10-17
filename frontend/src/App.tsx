import { useEffect, useState } from 'react';

export default function App() {
  const [status, setStatus] = useState<string>('Connecting to backend...');
  const [error, setError] = useState<boolean>(false);

  useEffect(() => {
    fetch('http://localhost:5001/api/health')
      .then((res) => {
        if (!res.ok) throw new Error('Network error');
        return res.json();
      })
      .then((data) => {
        console.log("Response from backend:", data);
        setStatus(data.message);
        setError(false);
      })
      .catch(() => {
        setStatus('Failed to connect to Express backend.');
        setError(true);
      });
      
  }, []);



  return (
    <div className="min-h-screen bg-slate-900 text-white flex flex-col items-center justify-center p-6">
      <div className="bg-slate-800 border border-slate-700 rounded-xl p-8 max-w-md w-full text-center shadow-2xl">
        <h1 className="text-3xl font-extrabold text-blue-400 mb-2">AuthorSync</h1>
        <p className="text-slate-400 text-sm mb-6">PERN Stack Base Setup</p>

        <div className="p-4 rounded-lg bg-slate-950 border border-slate-800">
          <p className="text-xs uppercase tracking-wider text-slate-500 font-bold mb-1">
            Backend Connection Status
          </p>
          <p className={`text-base font-semibold ${error ? 'text-red-400' : 'text-emerald-400'}`}>
            {status}
          </p>
        </div>
      </div>
    </div>
  );
}