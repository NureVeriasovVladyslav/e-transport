import { type RouteConfig, index, route } from "@react-router/dev/routes";

export default [
    index("routes/home.tsx"),
    route( "dashboard","routes/dashboard.tsx"),
    route("page", "dashboard/page.tsx"),
    route("analytics", "routes/analytics.tsx"),
    route("user/:id", "routes/user.tsx"),
] satisfies RouteConfig;
