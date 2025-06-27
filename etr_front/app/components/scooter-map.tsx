import React, { useEffect, useRef } from "react";
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";

mapboxgl.accessToken = import.meta.env.VITE_API_MAPBOX_TOKEN || "";
const access_token = import.meta.env.VITE_API_ACCESS_TOKEN as string;

type Scooter = {
  id: string;
  currentLocation: {
    latitude: number;
    longitude: number;
  };
  status: string;
};

type Props = {
  center?: [number, number];
  zoom?: number;
};

export const ScooterMap: React.FC<Props> = ({
  center = [	30.52, 50.46], // Росток
  zoom = 12,
}) => {
  const mapRef = useRef<HTMLDivElement>(null);

  const api = import.meta.env.VITE_API_URL || 'http://localhost:3000';

  // const vehicle = await fetch(`${api}/vehicle`, { headers: { Authorization: `Bearer ${access_token}` } });
  // console.log("ScooterMap vehicle fetch", vehicle);

  useEffect(() => {
    if (!mapRef.current) return;

    const map = new mapboxgl.Map({
      container: mapRef.current,
      style: "mapbox://styles/mapbox/streets-v12",
      center,
      zoom,
    });

    const api = import.meta.env.VITE_API_URL || "http://localhost:3000";
    // Отримання самокатів з API
    fetch(`${api}/vehicle`, {
      headers: { Authorization: `Bearer ${access_token}` },
    })
      .then(async (res) => {
        if (!res.ok) {
          throw new Error(`Vehicle fetch failed: ${res.status} ${res.statusText}`);
        }
        const data = await res.json();
        console.log("ScooterMap fetch raw:", data);

        // Перевірка формату даних
        if (!Array.isArray(data)) {
          throw new Error("Vehicle API did not return an array");
        }
        return data as Scooter[];
      })
      .then((scooters) => {
        scooters.forEach((scooter) => {
          const { currentLocation } = scooter;
          if (
            currentLocation &&
            typeof currentLocation.longitude === "number" &&
            typeof currentLocation.latitude === "number"
          ) {
            new mapboxgl.Marker({ color: "#ff5722" })
              .setLngLat([currentLocation.longitude, currentLocation.latitude])
              .addTo(map);
          } else {
            console.warn("Invalid location for scooter:", scooter);
          }
        });
        console.log("ScooterMap parsed:", scooters);
      })
      .catch((err) => {
        console.error("Error loading scooters:", err);
      });

    const observer = new ResizeObserver(() => {
      map.resize();
    });
    observer.observe(mapRef.current);

    return () => {
      map.remove();
      observer.disconnect();
    };
  }, []);

  return (
    <div
      className="w-full h-[500px] rounded-xl overflow-hidden shadow-md"
      ref={mapRef}
    />
  );
};
