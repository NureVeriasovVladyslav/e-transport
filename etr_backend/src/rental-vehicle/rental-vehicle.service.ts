import { Injectable, NotFoundException } from '@nestjs/common';
import { RentalVehicleDto } from './dtos/rental-vehicle.dto';
import { UpdateRentalVehicleDto } from './dtos/update-rental-vehicle.dto';
import { CreateRentalVehicleDto } from './dtos/create-rental-vehicle.dto';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class RentalVehicleService {
    constructor(private prisma: PrismaService) { }

    async findAllRentalVehicle(): Promise<RentalVehicleDto[]> {
        const result = await this.prisma.rentalVehicle.findMany();
        return result;
    }

    async createRentalVehicle(rentalVehicle: RentalVehicleDto): Promise<CreateRentalVehicleDto> {
        const result = await this.prisma.rentalVehicle.create({ data: { ...rentalVehicle } });
        return result;
    }

    async updateRentalVehicle(rentalVehicle: UpdateRentalVehicleDto, id: string): Promise<CreateRentalVehicleDto> {
        const result = await this.prisma.rentalVehicle.update({ data: { ...rentalVehicle }, where: { id: id } });
        return result;
    }

    async deleteRentalVehicle(id: string): Promise<CreateRentalVehicleDto> {
        const result = await this.prisma.rentalVehicle.delete({ where: { id: id } });
        return result;
    }

    async findRentalVehicle(vehicleId: string, rentalId: string): Promise<CreateRentalVehicleDto> {
        const result = await this.prisma.rentalVehicle.findFirst({ where: { vehicleId: vehicleId, rentalId: rentalId } });
        return result;
    }
    async findByVehicleAndRental(
        vehicleId: string,
        rentalId: string,
    ): Promise<CreateRentalVehicleDto> {
        const rv = await this.prisma.rentalVehicle.findFirst({
            where: { vehicleId, rentalId },
        });

        if (!rv) {
            throw new NotFoundException(
                `RentalVehicle not found for vehicle=${vehicleId} rental=${rentalId}`,
            );
        }
        return rv;
    }
}

