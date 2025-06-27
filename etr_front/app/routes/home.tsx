import type { Route } from "./+types/home";
// import { Welcome } from "../welcome/welcome";
import { AppSidebar } from "@/components/app-sidebar"
import { DataTableUser } from "@/components/data-table-users"
import { SiteHeader } from "@/components/site-header"
import {
    SidebarInset,
    SidebarProvider,
} from "@/components/ui/sidebar"

export function meta({ }: Route.MetaArgs) {
  return [
    { title: "New React Router App" },
    { name: "description", content: "Welcome to React Router!" },
  ];
}

export default function Home() {
  return <>
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
              WELLCOME HOME!
              
            </div>
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>

  </>;
}
