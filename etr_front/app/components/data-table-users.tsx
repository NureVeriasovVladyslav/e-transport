import * as React from "react"
import {
  closestCenter,
  DndContext,
  KeyboardSensor,
  MouseSensor,
  TouchSensor,
  useSensor,
  useSensors,
  type DragEndEvent,
  type UniqueIdentifier,
} from "@dnd-kit/core"
import { restrictToVerticalAxis } from "@dnd-kit/modifiers"
import {
  arrayMove,
  SortableContext,
  useSortable,
  verticalListSortingStrategy,
} from "@dnd-kit/sortable"
import { CSS } from "@dnd-kit/utilities"
import {
  IconChevronDown,
  IconChevronLeft,
  IconChevronRight,
  IconChevronsLeft,
  IconChevronsRight,
  IconCircleCheckFilled,
  IconDotsVertical,
  IconGripVertical,
  IconLayoutColumns,
  IconLoader,
  IconPlus,
  IconTrendingUp,
} from "@tabler/icons-react"
import {
  type ColumnDef,
  type ColumnFiltersState,
  flexRender,
  getCoreRowModel,
  getFacetedRowModel,
  getFacetedUniqueValues,
  getFilteredRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  type Row,
  type SortingState,
  useReactTable,
  type VisibilityState,
} from "@tanstack/react-table"
import { Area, AreaChart, CartesianGrid, XAxis } from "recharts"
import { toast } from "sonner"
import { z } from "zod"

import { useIsMobile } from "@/hooks/use-mobile"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  type ChartConfig,
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart"
import { Checkbox } from "@/components/ui/checkbox"
import {
  Drawer,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerFooter,
  DrawerHeader,
  DrawerTitle,
  DrawerTrigger,
} from "@/components/ui/drawer"
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Separator } from "@/components/ui/separator"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from "@/components/ui/tabs"
import { useEffect, useState } from "react"
import { AddVehicleButton } from "./add-vehicle-button"
import { useNavigate } from "react-router";

const handleDelete = async (id: string) => {
  const confirmed = confirm("Are you sure you want to delete this user?");
  if (!confirmed) return;

  try {
    const res = await fetch(`${import.meta.env.VITE_API_URL}/user/${id}`, {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${import.meta.env.VITE_API_ACCESS_TOKEN}`,
      },
    });

    if (!res.ok) throw new Error("Failed to delete user");

  } catch (err) {
    console.error("Delete error:", err);
    alert("Failed to delete user.");
  }
};

// function userToRow(: any) {
//   return {
//     id: scooter.id,
//     releaseDate: scooter.releaseDate,
//     status: scooter.status,
//     latitude: scooter.currentLocation?.latitude?.toString() ?? "",
//     longitude: scooter.currentLocation?.longitude?.toString() ?? "",
//     runnedDistance: scooter.runnedDistance,
//   };
// }

export default function UserTablePage() {
  const [data, setData] = useState<z.infer<typeof schema>[]>([]);
  const api = import.meta.env.VITE_API_URL || "http://localhost:3000";
  const access_token = import.meta.env.VITE_API_ACCESS_TOKEN as string;

  useEffect(() => {
    fetch(`${api}/user`, {
      headers: { Authorization: `Bearer ${access_token}` },
    })
      .then((res) => res.json())
      .then((users) => {
        // Перевірка, що users — масив
        if (Array.isArray(users)) {
          setData(users); // Якщо API повертає масив користувачів
        } else if (Array.isArray(users.users)) {
          setData(users.users); // Якщо API повертає { users: [...] }
        } else {
          setData([]); // Якщо нічого не повернулося або структура неочікувана
        }
      })
      .catch((err) => {
        console.error("Error fetching users:", err);
        setData([]);
      });
  }, []);


  return <DataTableUser data={data} />;
}

export const schema = z.object({
  id: z.string(),
  email: z.string(),
  name: z.string(),
  phoneNumber: z.string(),
  bonusAccount: z.string(),
  notification: z.boolean(),
  role: z.string(),
});

// Create a separate component for the drag handle
function DragHandle({ id }: { id: string }) {
  const { attributes, listeners } = useSortable({
    id,
  })

  return (
    <Button
      {...attributes}
      {...listeners}
      variant="ghost"
      size="icon"
      className="text-muted-foreground size-7 hover:bg-transparent"
    >
      <IconGripVertical className="text-muted-foreground size-3" />
      <span className="sr-only">Drag to reorder</span>
    </Button>
  )
}

const columns: ColumnDef<z.infer<typeof schema>>[] = [
  // export const columns = (handleDelete: (id: string) => void): ColumnDef<z.infer<typeof schema>>[] => [
  {
    id: "drag",
    header: () => null,
    cell: ({ row }) => <DragHandle id={row.original.id} />,
  },
  {
    id: "select",
    header: ({ table }) => (
      <div className="flex items-center justify-center">
        <Checkbox
          checked={
            table.getIsAllPageRowsSelected() ||
            (table.getIsSomePageRowsSelected() && "indeterminate")
          }
          onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
          aria-label="Select all"
        />
      </div>
    ),
    cell: ({ row }) => (
      <div className="flex items-center justify-center">
        <Checkbox
          checked={row.getIsSelected()}
          onCheckedChange={(value) => row.toggleSelected(!!value)}
          aria-label="Select row"
        />
      </div>
    ),
    enableSorting: false,
    enableHiding: false,
  },
  // {
  //   accessorKey: "id",
  //   header: "User",
  //   cell: ({ row }) => {
  //     const navigate = useNavigate();
  //     navigate(`/user/${row.original.id}`)
  //     // return <TableCellViewer item={row.original} />
  //   },
  // // cell: ({ row }) => row.original.id,
  //   enableHiding: false,
  // },
  {
    accessorKey: "id",
    header: "User",
    cell: ({ row }) => {
      const navigate = useNavigate();
      return (
        <span
          style={{ color: "#2563eb", cursor: "pointer", textDecoration: "underline" }}
          onClick={() => navigate(`/user/${row.original.id}`)}
        >
          {row.original.id}
        </span>
      );
    },
    enableHiding: false,
  },
  {
    accessorKey: "email",
    header: "Email",
    cell: ({ row }) => (
      <div className="w-32">
        <Badge variant="outline" className="text-muted-foreground px-1.5">
          {row.original.email}
        </Badge>
      </div>
    ),
  },
  {
    accessorKey: "name",
    header: "Name",
    cell: ({ row }) => row.original.name,
  },
  {
    accessorKey: "phoneNumber",
    header: "Phone number",
    cell: ({ row }) => row.original.phoneNumber,
  },
  {
    accessorKey: "bonusAccount",
    header: "Bonus account",
    cell: ({ row }) => row.original.bonusAccount,
  },
  {
    accessorKey: "role",
    header: "Role",
    cell: ({ row }) => row.original.role,
  },

  {
    id: "actions",
    cell: ({ row }) => (
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button
            variant="ghost"
            className="data-[state=open]:bg-muted text-muted-foreground flex size-8"
            size="icon"
          >
            <IconDotsVertical />
            <span className="sr-only">Open menu</span>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-32">
          {/* variant="destructive" onSelect={() => handleEdit(row)} */}
          <DropdownMenuItem >Edit</DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem variant="destructive" onSelect={() => handleDelete(row.id)}>
            Delete
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    ),
  },
]

function DraggableRow({ row }: { row: Row<z.infer<typeof schema>> }) {
  const { transform, transition, setNodeRef, isDragging } = useSortable({
    id: row.original.id,
  })

  return (
    <TableRow
      data-state={row.getIsSelected() && "selected"}
      data-dragging={isDragging}
      ref={setNodeRef}
      className="relative z-0 data-[dragging=true]:z-10 data-[dragging=true]:opacity-80"
      style={{
        transform: CSS.Transform.toString(transform),
        transition: transition,
      }}
    >
      {row.getVisibleCells().map((cell) => (
        <TableCell key={cell.id}>
          {flexRender(cell.column.columnDef.cell, cell.getContext())}
        </TableCell>
      ))}
    </TableRow>
  )
}

export function DataTableUser({
  data: initialData,
}: {
  data: z.infer<typeof schema>[]
}) {
  const [data, setData] = React.useState(() => initialData)
  const [rowSelection, setRowSelection] = React.useState({})
  const [columnVisibility, setColumnVisibility] =
    React.useState<VisibilityState>({})
  const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>(
    []
  )
  const [sorting, setSorting] = React.useState<SortingState>([])
  const [pagination, setPagination] = React.useState({
    pageIndex: 0,
    pageSize: 10,
  })
  const sortableId = React.useId()
  const sensors = useSensors(
    useSensor(MouseSensor, {}),
    useSensor(TouchSensor, {}),
    useSensor(KeyboardSensor, {})
  )

  const dataIds = React.useMemo<UniqueIdentifier[]>(
    () => data?.map(({ id }) => id) || [],
    [data]
  )

  const table = useReactTable({
    data,
    columns,
    state: {
      sorting,
      columnVisibility,
      rowSelection,
      columnFilters,
      pagination,
    },
    getRowId: (row) => row.id.toString(),
    enableRowSelection: true,
    onRowSelectionChange: setRowSelection,
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    onColumnVisibilityChange: setColumnVisibility,
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFacetedRowModel: getFacetedRowModel(),
    getFacetedUniqueValues: getFacetedUniqueValues(),
  });

  // Add this function to reload vehicles after adding a new one
  const reloadVehicles = async () => {
    try {
      const api = import.meta.env.VITE_API_URL || "http://localhost:3000";
      const access_token = import.meta.env.VITE_API_ACCESS_TOKEN as string;
      const res = await fetch(`${api}/user`, {
        headers: { Authorization: `Bearer ${access_token}` },
      });
      const users = await res.json();
      const mapped = users.map();
      setData(mapped);
    } catch (err) {
      toast.error("Помилка при оновленні списку!");
      console.error(err);
    }
  };

  function handleDragEnd(event: DragEndEvent) {
    const { active, over } = event
    if (active && over && active.id !== over.id) {
      setData((data) => {
        const oldIndex = dataIds.indexOf(active.id)
        const newIndex = dataIds.indexOf(over.id)
        return arrayMove(data, oldIndex, newIndex)
      })
    }
  }

  return (
    <Tabs
      defaultValue="outline"
      className="w-full flex-col justify-start gap-6"
    >
      <div className="flex items-center justify-between px-4 lg:px-6">
        <Label htmlFor="view-selector" className="sr-only">
          View
        </Label>
        <Select defaultValue="outline">
          <SelectTrigger
            className="flex w-fit @4xl/main:hidden"
            size="sm"
            id="view-selector"
          >
            <SelectValue placeholder="Select a view" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="outline">Outline</SelectItem>
            <SelectItem value="past-performance">Past Performance</SelectItem>
            <SelectItem value="key-personnel">Key Personnel</SelectItem>
            <SelectItem value="focus-documents">Focus Documents</SelectItem>
          </SelectContent>
        </Select>
        <TabsList className="**:data-[slot=badge]:bg-muted-foreground/30 hidden **:data-[slot=badge]:size-5 **:data-[slot=badge]:rounded-full **:data-[slot=badge]:px-1 @4xl/main:flex">
          <TabsTrigger value="outline">Outline</TabsTrigger>
          <TabsTrigger value="past-performance">
            Past Performance <Badge variant="secondary">3</Badge>
          </TabsTrigger>
          <TabsTrigger value="key-personnel">
            Key Personnel <Badge variant="secondary">2</Badge>
          </TabsTrigger>
          <TabsTrigger value="focus-documents">Focus Documents</TabsTrigger>
        </TabsList>
        <div className="flex items-center gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm">
                <IconLayoutColumns />
                <span className="hidden lg:inline">Customize Columns</span>
                <span className="lg:hidden">Columns</span>
                <IconChevronDown />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
              {table
                .getAllColumns()
                .filter(
                  (column) =>
                    typeof column.accessorFn !== "undefined" &&
                    column.getCanHide()
                )
                .map((column) => {
                  return (
                    <DropdownMenuCheckboxItem
                      key={column.id}
                      className="capitalize"
                      checked={column.getIsVisible()}
                      onCheckedChange={(value) =>
                        column.toggleVisibility(!!value)
                      }
                    >
                      {column.id}
                    </DropdownMenuCheckboxItem>
                  )
                })}
            </DropdownMenuContent>
          </DropdownMenu>
          <AddVehicleButton onAdded={reloadVehicles} />
        </div>
      </div>
      <TabsContent
        value="outline"
        className="relative flex flex-col gap-4 overflow-auto px-4 lg:px-6"
      >
        <div className="overflow-hidden rounded-lg border">
          <DndContext
            collisionDetection={closestCenter}
            modifiers={[restrictToVerticalAxis]}
            onDragEnd={handleDragEnd}
            sensors={sensors}
            id={sortableId}
          >
            <Table>
              <TableHeader className="bg-muted sticky top-0 z-10">
                {table.getHeaderGroups().map((headerGroup) => (
                  <TableRow key={headerGroup.id}>
                    {headerGroup.headers.map((header) => {
                      return (
                        <TableHead key={header.id} colSpan={header.colSpan}>
                          {header.isPlaceholder
                            ? null
                            : flexRender(
                              header.column.columnDef.header,
                              header.getContext()
                            )}
                        </TableHead>
                      )
                    })}
                  </TableRow>
                ))}
              </TableHeader>
              <TableBody className="**:data-[slot=table-cell]:first:w-8">
                {table.getRowModel().rows?.length ? (
                  <SortableContext
                    items={dataIds}
                    strategy={verticalListSortingStrategy}
                  >
                    {table.getRowModel().rows.map((row) => (
                      <DraggableRow key={row.id} row={row} />
                    ))}
                  </SortableContext>
                ) : (
                  <TableRow>
                    <TableCell
                      colSpan={columns.length}
                      className="h-24 text-center"
                    >
                      No results.
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </DndContext>
        </div>
        <div className="flex items-center justify-between px-4">
          <div className="text-muted-foreground hidden flex-1 text-sm lg:flex">
            {table.getFilteredSelectedRowModel().rows.length} of{" "}
            {table.getFilteredRowModel().rows.length} row(s) selected.
          </div>
          <div className="flex w-full items-center gap-8 lg:w-fit">
            <div className="hidden items-center gap-2 lg:flex">
              <Label htmlFor="rows-per-page" className="text-sm font-medium">
                Rows per page
              </Label>
              <Select
                value={`${table.getState().pagination.pageSize}`}
                onValueChange={(value) => {
                  table.setPageSize(Number(value))
                }}
              >
                <SelectTrigger size="sm" className="w-20" id="rows-per-page">
                  <SelectValue
                    placeholder={table.getState().pagination.pageSize}
                  />
                </SelectTrigger>
                <SelectContent side="top">
                  {[10, 20, 30, 40, 50].map((pageSize) => (
                    <SelectItem key={pageSize} value={`${pageSize}`}>
                      {pageSize}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="flex w-fit items-center justify-center text-sm font-medium">
              Page {table.getState().pagination.pageIndex + 1} of{" "}
              {table.getPageCount()}
            </div>
            <div className="ml-auto flex items-center gap-2 lg:ml-0">
              <Button
                variant="outline"
                className="hidden h-8 w-8 p-0 lg:flex"
                onClick={() => table.setPageIndex(0)}
                disabled={!table.getCanPreviousPage()}
              >
                <span className="sr-only">Go to first page</span>
                <IconChevronsLeft />
              </Button>
              <Button
                variant="outline"
                className="size-8"
                size="icon"
                onClick={() => table.previousPage()}
                disabled={!table.getCanPreviousPage()}
              >
                <span className="sr-only">Go to previous page</span>
                <IconChevronLeft />
              </Button>
              <Button
                variant="outline"
                className="size-8"
                size="icon"
                onClick={() => table.nextPage()}
                disabled={!table.getCanNextPage()}
              >
                <span className="sr-only">Go to next page</span>
                <IconChevronRight />
              </Button>
              <Button
                variant="outline"
                className="hidden size-8 lg:flex"
                size="icon"
                onClick={() => table.setPageIndex(table.getPageCount() - 1)}
                disabled={!table.getCanNextPage()}
              >
                <span className="sr-only">Go to last page</span>
                <IconChevronsRight />
              </Button>
            </div>
          </div>
        </div>
      </TabsContent>
      <TabsContent
        value="past-performance"
        className="flex flex-col px-4 lg:px-6"
      >
        <div className="aspect-video w-full flex-1 rounded-lg border border-dashed"></div>
      </TabsContent>
      <TabsContent value="key-personnel" className="flex flex-col px-4 lg:px-6">
        <div className="aspect-video w-full flex-1 rounded-lg border border-dashed"></div>
      </TabsContent>
      <TabsContent
        value="focus-documents"
        className="flex flex-col px-4 lg:px-6"
      >
        <div className="aspect-video w-full flex-1 rounded-lg border border-dashed"></div>
      </TabsContent>
    </Tabs>
  )
}

// function TableCellViewer({ item }: { item: z.infer<typeof schema> }) {
//   const isMobile = useIsMobile()
//   const [form, setForm] = useState({
//     status: item.status,
//     runnedDistance: item.runnedDistance,
//     releaseDate: item.releaseDate,
//     latitude: item.latitude,
//     longitude: item.longitude,
//   });
//   const [loading, setLoading] = useState(false);

//   const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
//     setForm({ ...form, [e.target.id]: e.target.value });
//   };

//   const handleSelect = (field: string, value: string) => {
//     setForm({ ...form, [field]: value });
//   };

//   const handleSubmit = async (e: React.FormEvent) => {
//     e.preventDefault();
//     setLoading(true);
//     try {
//       const api = import.meta.env.VITE_API_URL || "http://localhost:3000";
//       const access_token = import.meta.env.VITE_API_ACCESS_TOKEN as string;
//       const res = await fetch(`${api}/vehicle/${item.id}`, {
//         method: "PUT",
//         headers: {
//           "Content-Type": "application/json",
//           Authorization: `Bearer ${access_token}`,
//         },
//         body: JSON.stringify({
//           status: form.status,
//           runnedDistance: Number(form.runnedDistance),
//           releaseDate: form.releaseDate,
//           currentLocation: {
//             latitude: Number(form.latitude),
//             longitude: Number(form.longitude),
//           },
//         }),
//       });
//       if (!res.ok) throw new Error("Failed to update vehicle");
//       toast.success("Дані оновлено!");
//     } catch (err) {
//       toast.error("Помилка при оновленні!");
//       console.error(err);
//     } finally {
//       setLoading(false);
//     }
//   };

//   return (
//     <Drawer direction="right">
//       <DrawerTrigger asChild>
//         <Button variant="link" className="text-foreground w-fit px-0 text-left">
//           {item.id}
//         </Button>
//       </DrawerTrigger>
//       <DrawerContent>
//         <DrawerHeader className="gap-1">
//           <DrawerTitle>{item.id}</DrawerTitle>
//           <DrawerDescription>Редагування даних самоката</DrawerDescription>
//         </DrawerHeader>
//         <form className="flex flex-col gap-4 px-4 text-sm" onSubmit={handleSubmit}>
//           {!isMobile && (
//             <>
//               <ChartContainer config={chartConfig}>
//                 <AreaChart
//                   accessibilityLayer
//                   data={chartData}
//                   margin={{
//                     left: 0,
//                     right: 10,
//                   }}
//                 >
//                   <CartesianGrid vertical={false} />
//                   <XAxis
//                     dataKey="month"
//                     tickLine={false}
//                     axisLine={false}
//                     tickMargin={8}
//                     tickFormatter={(value) => value.slice(0, 3)}
//                     hide
//                   />
//                   <ChartTooltip
//                     cursor={false}
//                     content={<ChartTooltipContent indicator="dot" />}
//                   />
//                   <Area
//                     dataKey="mobile"
//                     type="natural"
//                     fill="var(--color-mobile)"
//                     fillOpacity={0.6}
//                     stroke="var(--color-mobile)"
//                     stackId="a"
//                   />
//                   <Area
//                     dataKey="desktop"
//                     type="natural"
//                     fill="var(--color-desktop)"
//                     fillOpacity={0.4}
//                     stroke="var(--color-desktop)"
//                     stackId="a"
//                   />
//                 </AreaChart>
//               </ChartContainer>
//               <Separator />
//               <div className="grid gap-2">
//                 <div className="flex gap-2 leading-none font-medium">
//                   Trending up by 5.2% this month{" "}
//                   <IconTrendingUp className="size-4" />
//                 </div>
//                 <div className="text-muted-foreground">
//                   Showing total visitors for the last 6 months. This is just
//                   some random text to test the layout. It spans multiple lines
//                   and should wrap around.
//                 </div>
//               </div>
//               <Separator />
//             </>
//           )}
//           <div className="grid grid-cols-2 gap-4">
//             <div className="flex flex-col gap-3">
//               <Label htmlFor="releaseDate">Release Date</Label>
//               <Input
//                 id="releaseDate"
//                 value={form.releaseDate}
//                 onChange={handleChange}
//                 type="date"
//               />
//             </div>
//             <div className="flex flex-col gap-3">
//               <Label htmlFor="status">Status</Label>
//               <Select value={form.status} onValueChange={v => handleSelect("status", v)}>
//                 <SelectTrigger id="status" className="w-full">
//                   <SelectValue placeholder="Select a status" />
//                 </SelectTrigger>
//                 <SelectContent>
//                   <SelectItem value="FREE">FREE</SelectItem>
//                   <SelectItem value="INUSE">INUSE</SelectItem>
//                   <SelectItem value="NOTAVAILABLE">NOTAVAILABLE</SelectItem>
//                   <SelectItem value="BROKEN">BROKEN</SelectItem>
//                   <SelectItem value="REPAIR">REPAIR</SelectItem>
//                 </SelectContent>
//               </Select>
//             </div>
//           </div>
//           <div className="grid grid-cols-2 gap-4">
//             <div className="flex flex-col gap-3">
//               <Label htmlFor="runnedDistance">Runned Distance</Label>
//               <Input
//                 id="runnedDistance"
//                 value={form.runnedDistance}
//                 onChange={handleChange}
//                 type="number"
//                 step="0.01"
//               />
//             </div>
//             <div className="flex flex-col gap-3">
//               <Label htmlFor="latitude">Latitude</Label>
//               <Input
//                 id="latitude"
//                 value={form.latitude}
//                 onChange={handleChange}
//                 type="number"
//                 step="0.0001"
//               />
//             </div>
//             <div className="flex flex-col gap-3">
//               <Label htmlFor="longitude">Longitude</Label>
//               <Input
//                 id="longitude"
//                 value={form.longitude}
//                 onChange={handleChange}
//                 type="number"
//                 step="0.0001"
//               />
//             </div>
//           </div>
//           <DrawerFooter>
//             <Button type="submit" disabled={loading}>
//               {loading ? "Зберігаю..." : "Зберегти"}
//             </Button>
//             <DrawerClose asChild>
//               <Button variant="outline">Закрити</Button>
//             </DrawerClose>
//           </DrawerFooter>
//         </form>
//       </DrawerContent>
//     </Drawer>
//   );
// }
// 