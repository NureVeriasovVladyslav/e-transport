import { AppSidebar } from "@/components/app-sidebar"
import { ChartAreaInteractive } from "@/components/chart-area-interactive"
import { DataTableUser } from "@/components/data-table-users"
import { SectionCards } from "@/components/section-cards"
import { SiteHeader } from "@/components/site-header"
import {
    SidebarInset,
    SidebarProvider,
} from "@/components/ui/sidebar"
import { useLoaderData } from "react-router"

export const loader = async () => {
    try {
        const api = import.meta.env.VITE_API_URL || 'http://localhost:3000';
        const access_token = import.meta.env.VITE_API_ACCESS_TOKEN as string;
        const [usersRes] = await Promise.all([
            fetch(`${api}/user`, { headers: { Authorization: `Bearer ${access_token}` } }),
        ]);
        if (!usersRes.ok) throw new Error('Fetch failed');
        const users = await usersRes.json();
        return {users};
    }
    catch (e) {
        console.error("Combined loader error", e);
        return { rides: 0, scooters: 0, revenue: 0, users: 0, chartData: [], data: [] };
    }
};

type TableRow = {
    id: string;
    email: string;
    name: string;
    phoneNumber: string;
    bonusAccount: string;
    notification: boolean;
    role: string;
};



export default function Analytics() {
    const { users } = useLoaderData() as { users: TableRow[] };

    // // const stats = useLoaderData() as { rides: number; scooters: number; revenue: number; users: number };
    // const chartData = useRouteLoaderData("dashboard-activity") as ChartDataPoint[];

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
                            {/* <SectionCards rides={rides} scooters={scooters} revenue={revenue} users={users} /> */}
                            <DataTableUser data={users} />
                        </div>
                    </div>
                </div>
            </SidebarInset>
        </SidebarProvider>
    )
}
