import React, { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Drawer, DrawerTrigger, DrawerContent, DrawerHeader, DrawerTitle, DrawerFooter, DrawerClose } from "@/components/ui/drawer";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";
import { IconPlus } from "@tabler/icons-react";

export function AddVehicleButton({ onAdded }: { onAdded?: () => void }) {
  const [open, setOpen] = useState(false);
  const [latitude, setLatitude] = useState("");
  const [longitude, setLongitude] = useState("");
  const [loading, setLoading] = useState(false);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const api = import.meta.env.VITE_API_URL || "http://localhost:3000";
      const access_token = import.meta.env.VITE_API_ACCESS_TOKEN as string;
      const res = await fetch(`${api}/vehicle`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${access_token}`,
        },
        body: JSON.stringify({
          status: "FREE",
          runnedDistance: 0,
          releaseDate: new Date().toISOString().slice(0, 10), // або інший формат, якщо треба
          currentLocation: {
            latitude: Number(latitude),
            longitude: Number(longitude),
          },
        }),
      });
      if (!res.ok) throw new Error("Failed to add vehicle");
      toast.success("Самокат додано!");
      setOpen(false);
      setLatitude("");
      setLongitude("");
      if (onAdded) onAdded();
    } catch (err) {
      toast.error("Помилка при додаванні!");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Drawer open={open} onOpenChange={setOpen} direction="right">
      <DrawerTrigger asChild>
        <Button variant="outline" size="sm">
          <IconPlus />
          <span className="hidden lg:inline">Add Vehicle</span>
        </Button>
      </DrawerTrigger>
      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>Додати новий самокат</DrawerTitle>
        </DrawerHeader>
        <form className="flex flex-col gap-4 px-4" onSubmit={handleAdd}>
          <div className="flex flex-col gap-2">
            <Label htmlFor="latitude">Latitude</Label>
            <Input
              id="latitude"
              type="number"
              step="0.0001"
              value={latitude}
              onChange={e => setLatitude(e.target.value)}
              required
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="longitude">Longitude</Label>
            <Input
              id="longitude"
              type="number"
              step="0.0001"
              value={longitude}
              onChange={e => setLongitude(e.target.value)}
              required
            />
          </div>
          <DrawerFooter>
            <Button type="submit" disabled={loading}>
              {loading ? "Додаю..." : "Додати"}
            </Button>
            <DrawerClose asChild>
              <Button variant="outline" type="button">
                Скасувати
              </Button>
            </DrawerClose>
          </DrawerFooter>
        </form>
      </DrawerContent>
    </Drawer>
  );
}
