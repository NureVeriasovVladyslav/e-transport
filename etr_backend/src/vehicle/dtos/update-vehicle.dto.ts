import { ApiProperty } from '@nestjs/swagger';
import { VehicleStatus } from '@prisma/client';
import { JsonValue } from '@prisma/client/runtime/library';
import { IsBoolean, IsEmail, IsEnum, IsJSON, IsNotEmpty, IsNumber, IsOptional, IsString, IsUUID, isBoolean } from 'class-validator';

export class UpdateVehicleDto {

    @ApiProperty({
        enum: VehicleStatus,
    })
    @IsEnum(VehicleStatus)
    @IsNotEmpty()
    @IsOptional()
    status: VehicleStatus

    @ApiProperty({
        type: Number,
        required: false,
    })
    @IsNumber()
    @IsOptional()
    runnedDistance: number

    @ApiProperty({
        type: String,
        required: false,
    })
    @IsString()
    @IsOptional()
    releaseDate: string

    @ApiProperty({
        type: Object,
        required: false,
    })
    @IsJSON()
    @IsOptional()
    currentLocation: JsonValue

}