import { AppSidebar } from "@/components/app-sidebar"
import { ChartAreaInteractive } from "@/components/chart-area-interactive"
import { DataTable } from "@/components/data-table"
import { SectionCards } from "@/components/section-cards"
import { SiteHeader } from "@/components/site-header"
import {
  SidebarInset,
  SidebarProvider,
} from "@/components/ui/sidebar"

// import data from "./data.json"
import { useLoaderData, useRouteLoaderData } from "react-router"
import mapboxgl from "mapbox-gl";
import { useEffect, useRef } from "react"
import { ScooterMap } from "@/components/scooter-map"
import ScooterTable from "@/components/scooter-table"

mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_TOKEN as string;


const access_token = import.meta.env.VITE_API_ACCESS_TOKEN as string;


// export const loader = async () => {
//   try {
//     const api = import.meta.env.VITE_API_URL || 'http://localhost:3000';
//     // 1. Логін
//     // const { access_token } = await login();

//     // 2. Запит статистики з токеном
//     const res = await fetch(`${api}/stat`, {
//       headers: { Authorization: `Bearer ${access_token}` }
//     });
//     if (!res.ok) throw new Error('stats fetch failed');
//     return await res.json(); // { rides, scooters, revenue }
//   } catch (e) {
//     console.error('Stats loader error', e);
//     return { rides: 0, scooters: 0, revenue: 0, users: 0 };
//   }
// };

// export const loaderActivity = async () => {
//   try {
//     const api = import.meta.env.VITE_API_URL || 'http://localhost:3000';
//     const res = await fetch(`${api}/rental/activity/daily`, {
//       headers: { Authorization: `Bearer ${access_token}` }
//     });
//     if (!res.ok) throw new Error('Activity fetch failed');

//     const rawData: Record<string, number> = await res.json();

//     // Перетворюємо у формат [{ date: "...", rentals: ... }]
//     const chartData = Object.entries(rawData).map(([date, count]) => ({
//       date,
//       rentals: count
//     }));

//     return chartData;
//   } catch (e) {
//     console.error('Activity loader error', e);
//     return [];
//   }
// };
function scooterToRow(scooter: any) {
  return {
    id: scooter.id,
    releaseDate: scooter.releaseDate,
    status: scooter.status,
    latitude: scooter.currentLocation?.latitude?.toString() ?? "",
    longitude: scooter.currentLocation?.longitude?.toString() ?? "",
    runnedDistance: scooter.runnedDistance,
  };
}

export const loader = async () => {
  try {
    const api = import.meta.env.VITE_API_URL || 'http://localhost:3000';
    const access_token = import.meta.env.VITE_API_ACCESS_TOKEN as string;

    const [statsRes, activityRes, vehiclesRes] = await Promise.all([
      fetch(`${api}/stat`, { headers: { Authorization: `Bearer ${access_token}` } }),
      fetch(`${api}/rental/activity/daily`, { headers: { Authorization: `Bearer ${access_token}` } }),
      fetch(`${api}/vehicle`, { headers: { Authorization: `Bearer ${access_token}` } }),
    ]);

    if (!statsRes.ok || !activityRes.ok || !vehiclesRes.ok) throw new Error('Fetch failed');

    const stats = await statsRes.json();
    const rawActivity = await activityRes.json();
    const vehicles = await vehiclesRes.json();

    function scooterToRow(scooter: any) {
  return {
    id: scooter.id,
    releaseDate: scooter.releaseDate,
    status: scooter.status,
    latitude: scooter.currentLocation?.latitude?.toString() ?? "",
    longitude: scooter.currentLocation?.longitude?.toString() ?? "",
    runnedDistance: scooter.runnedDistance,
  };
}
    // Мапінг у формат таблиці
    const data = vehicles.map(scooterToRow);

    const chartData = Object.entries(rawActivity).map(([date, count]) => ({
      date,
      rentals: count,
    }));

    return { ...stats, chartData, data };
  } catch (e) {
    console.error("Combined loader error", e);
    return { rides: 0, scooters: 0, revenue: 0, users: 0, chartData: [], data: [] };
  }
};


// export const loader = async () => {
//   try {
//     const api = import.meta.env.VITE_API_URL || 'http://localhost:3000';

//     const [statsRes, activityRes] = await Promise.all([
//       fetch(`${api}/stat`, { headers: { Authorization: `Bearer ${access_token}` } }),
//       fetch(`${api}/rental/activity/daily`, { headers: { Authorization: `Bearer ${access_token}` } }),
//     ]);

//     if (!statsRes.ok || !activityRes.ok) throw new Error('Fetch failed');

//     const stats = await statsRes.json();
//     const rawActivity = await activityRes.json();

//     const chartData = Object.entries(rawActivity).map(([date, count]) => ({
//       date,
//       rentals: count,
//     }));

//     return { ...stats, chartData };
//   } catch (e) {
//     console.error("Combined loader error", e);
//     return { rides: 0, scooters: 0, revenue: 0, users: 0, chartData: [] };
//   }
// };


type ChartDataPoint = { date: string; rentals: number };
type TableRow = {
  id: string;
  releaseDate: string;
  status: string;
  latitude: string;
  longitude: string;
  runnedDistance: number;
};
type Stats = { rides: number; scooters: number; revenue: number; users: number; chartData: ChartDataPoint[] };

export default function Page() {
  // const { rides, scooters, revenue, users} = useRouteLoaderData("dashboard") as Stats;

  // // const stats = useLoaderData() as { rides: number; scooters: number; revenue: number; users: number };
  // const chartData = useRouteLoaderData("dashboard-activity") as ChartDataPoint[];

  const { rides, scooters, revenue, users, chartData, data } = useLoaderData() as Stats & {
    chartData: { date: string; rentals: number }[];
    data: TableRow[];
  };

  return (
    <SidebarProvider
      style={
        {
          "--sidebar-width": "calc(var(--spacing) * 72)",
          "--header-height": "calc(var(--spacing) * 12)",
        } as React.CSSProperties
      }
    >
      <AppSidebar variant="inset" />
      <SidebarInset>
        <SiteHeader />
        <div className="flex flex-1 flex-col">
          <div className="@container/main flex flex-1 flex-col gap-2">
            <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6">
              <SectionCards rides={rides} scooters={scooters} revenue={revenue} users={users} />
              <div className="px-4 lg:px-6">
                <ChartAreaInteractive data={chartData} />
              </div>
              <DataTable data={data} />
              {/* <ScooterTable /> */}
              <div className="px-4 lg:px-6">
                <ScooterMap />
              </div>
            </div>
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  )
}
