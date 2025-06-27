import React, { useEffect, useState } from "react";

type Scooter = {
  id: string;
  status: string;
  runnedDistance: number;
  releaseDate: string;
  currentLocation: {
    latitude: number;
    longitude: number;
  };
};

export default function ScooterTable() {
  const [data, setData] = useState<Scooter[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const api = import.meta.env.VITE_API_URL || "http://localhost:3000";
    const access_token = import.meta.env.VITE_API_ACCESS_TOKEN as string;

    fetch(`${api}/vehicle`, {
      headers: { Authorization: `Bearer ${access_token}` },
    })
      .then((res) => res.json())
      .then((scooters: Scooter[]) => {
        setData(scooters);
        console.log("Scooter data from backend:", scooters);
      })
      .catch((err) => {
        console.error("Error fetching scooters:", err);
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div>Завантаження...</div>;

  return (
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Status</th>
          <th>Distance</th>
          <th>Release Date</th>
          <th>Latitude</th>
          <th>Longitude</th>
        </tr>
      </thead>
      <tbody>
        {data.map((scooter) => (
          <tr key={scooter.id}>
            <td>{scooter.id}</td>
            <td>{scooter.status}</td>
            <td>{scooter.runnedDistance.toFixed(2)}</td>
            <td>{new Date(scooter.releaseDate).toLocaleString()}</td>
            <td>{scooter.currentLocation.latitude}</td>
            <td>{scooter.currentLocation.longitude}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
