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

// src/pages/user-page.tsx
export const loader = async ({ params }: { params: { id: string } }) => {
    console.log("User loader params", params);
    console.log("User", params.id);
    try {
        const api = import.meta.env.VITE_API_URL || 'http://localhost:3000';
        const access_token = import.meta.env.VITE_API_ACCESS_TOKEN as string;
        const res = await fetch(`${api}/user/${params.id}`, {
            headers: { Authorization: `Bearer ${access_token}` }
        });
        if (!res.ok) throw new Error('Fetch failed');
        const user = await res.json();
        return { user };
    } catch (e) {
        console.error("User loader error", e);
        return { user: null };
    }
};


type Vehicle = {
    id: string;
    status: string;
    runnedDistance: number;
    releaseDate: string;
    currentLocation: {
        latitude: number;
        longitude: number;
    };
};

type RentalVehicle = {
    id: string;
    vehicleId: string;
    rentalId: string;
    vehicle?: Vehicle;
};

type Payment = {
    id: string;
    paymentMethod: string;
    amount: string;
    date: string;
    rentalId: string;
};

type Rental = {
    id: string;
    isActive: boolean;
    dateRented: string;
    dateReturned?: string;
    userId: string;
    startLocation: { latitude: number; longitude: number };
    endLocation: { latitude: number; longitude: number };
    distance: number;
    avgSpeed: number;
    maxSpeed: number;
    energyConsumed: number;
    rentalVehicle?: RentalVehicle[];
    payment?: Payment;
};

type User = {
    id: string;
    email: string;
    name: string;
    password: string;
    phoneNumber: string;
    bonusAccount: string;
    notification: boolean;
    role: string;
    photo?: string;
    rental?: Rental[];
};


export default function UserPage() {
    const { user } = useLoaderData() as { user: User };

    if (!user) return <div>Користувача не знайдено</div>;

    return (
        <SidebarProvider
            style={{
                "--sidebar-width": "calc(var(--spacing) * 72)",
                "--header-height": "calc(var(--spacing) * 12)",
            } as React.CSSProperties}
        >
            <AppSidebar variant="inset" />
            <SidebarInset>
                <SiteHeader />
                <div className="flex flex-1 flex-col p-6 gap-6">
                    <h1 className="text-2xl font-bold mb-4">Інформація про користувача</h1>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <p><b>ID:</b> {user.id}</p>
                            <p><b>Email:</b> {user.email}</p>
                            <p><b>Ім'я:</b> {user.name}</p>
                            <p><b>Телефон:</b> {user.phoneNumber}</p>
                            <p><b>Бонусний рахунок:</b> {user.bonusAccount}</p>
                            <p><b>Роль:</b> {user.role}</p>
                            <p><b>Сповіщення:</b> {user.notification ? "Так" : "Ні"}</p>
                        </div>
                        <div>
                            <b>Фото:</b>
                            <div>
                                {user.photo && user.photo !== "string" ? (
                                    <img src={user.photo} alt="Фото користувача" className="w-32 h-32 rounded-full" />
                                ) : (
                                    <span>Немає фото</span>
                                )}
                            </div>
                        </div>
                    </div>
                    <h2 className="text-xl font-semibold mt-6 mb-2">Оренди користувача</h2>
                    <div className="overflow-x-auto">
                        <table className="min-w-full border">
                            <thead>
                                <tr>
                                    <th>ID оренди</th>
                                    <th>Дата початку</th>
                                    <th>Дата завершення</th>
                                    <th>Відстань (км)</th>
                                    <th>Середня швидкість</th>
                                    <th>Транспорт</th>
                                    <th>Оплата</th>
                                </tr>
                            </thead>
                            <tbody>
                                {Array.isArray(user.rental) && user.rental.length > 0 ? (
                                    user.rental.map((r: Rental) => (
                                        <tr key={r.id}>
                                            <td>{r.id}</td>
                                            <td>{r.dateRented ? new Date(r.dateRented).toLocaleString() : "—"}</td>
                                            <td>{r.dateReturned ? new Date(r.dateReturned).toLocaleString() : "—"}</td>
                                            <td>{typeof r.distance === "number" ? r.distance.toFixed(2) : "—"}</td>
                                            <td>{typeof r.avgSpeed === "number" ? r.avgSpeed.toFixed(1) : "—"}</td>
                                            <td>
                                                {Array.isArray(r.rentalVehicle) && r.rentalVehicle.length > 0 ? (
                                                    r.rentalVehicle.map((rv: RentalVehicle) => (
                                                        <div key={rv.id}>
                                                            ID: {rv.vehicle?.id || "—"}<br />
                                                            Статус: {rv.vehicle?.status || "—"}
                                                        </div>
                                                    ))
                                                ) : (
                                                    <span>—</span>
                                                )}
                                            </td>
                                            <td>
                                                {r.payment ? (
                                                    <>
                                                        {r.payment.paymentMethod}<br />
                                                        {r.payment.amount} ₴<br />
                                                        {r.payment.date ? new Date(r.payment.date).toLocaleString() : "—"}
                                                    </>
                                                ) : "—"}
                                            </td>
                                        </tr>
                                    ))
                                ) : (
                                    <tr>
                                        <td colSpan={7} className="text-center">Оренд не знайдено</td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            </SidebarInset>
        </SidebarProvider>
    );
}