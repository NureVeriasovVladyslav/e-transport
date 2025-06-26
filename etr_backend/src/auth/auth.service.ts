// import { Injectable, UnauthorizedException, NotFoundException } from '@nestjs/common';
// import { UserService } from 'src/user/user.service';
// import { JwtService } from '@nestjs/jwt';
// import * as bcrypt from 'bcrypt';
// import { AuthEntity } from './auth.entity';
// import { PrismaService } from 'src/prisma/prisma.service';
// import 'dotenv/config';
// import { LoginDto } from './dtos/login.dto';
// import { UserDto } from 'src/user/dtos/user.dto';

// @Injectable()
// export class AuthService {
//   authService: any;
//   //   constructor(
//   //     private userService: UserService,
//   //     private jwtService: JwtService
//   //   ) {}
//   constructor(private prisma: PrismaService, private jwtService: JwtService) { }

//   async validateUser(email: string, pass: string): Promise<any> {
//     const user = await this.prisma.user.findUnique({ where: { email } });
//     if (user && await bcrypt.compare(pass, user.password)) {
//       const { password, ...result } = user;
//       return result;
//     }
//     return null;
//   }

//   // async login(user: any, options: { expiresIn: string; privateKey: string; }) {
//   //   const userData = await this.prisma.user.findUnique({
//   //     where: { email: user.email }
//   //   });
//   //   const payload = { email: user.email, sub: user.id, role: userData.role };
//   //   return {
//   //     access_token: this.jwtService.sign(payload, options),
//   //     email: user.email,
//   //   };
//   // }

//   async login(loginData: LoginDto, options: { expiresIn: string; privateKey: string; }) {
//   // Спочатку валідуємо користувача
//   const validatedUser = await this.validateUser(loginData.email, loginData.password);
  
//   if (!validatedUser) {
//     throw new UnauthorizedException('Invalid credentials');
//   }

//   // Отримуємо повні дані користувача
//   const userData = await this.prisma.user.findUnique({
//     where: { email: loginData.email }
//   });

//   if (!userData) {
//     throw new UnauthorizedException('User not found');
//   }

//   const payload = { 
//     email: userData.email, 
//     sub: userData.id, 
//     role: userData.role 
//   };

//   return {
//     access_token: this.jwtService.sign(payload, options),
//     email: userData.email,
//     user: {
//       id: userData.id,
//       email: userData.email,
//       name: userData.name,
//       role: userData.role
//     }
//   };
// }


//   async register(registerData: UserDto): Promise<any> {//registerData: RegisterDto) {
//     const saltRounds = 10;
//     const salt = await bcrypt.genSalt(saltRounds);
//     console.log("SALT", salt)
//     console.log("PASSWORD", registerData.password)
//     const hashedPassword = await bcrypt.hash(registerData.password, salt);
//     console.log("heshed", hashedPassword)
//     const user = await this.prisma.user.create({
//       data: {
//         email: registerData.email,
//         password: hashedPassword,
//         role: registerData.role,
//         name: registerData.name,
//         phoneNumber: registerData.phoneNumber,
//         bonusAccount: registerData.bonusAccount,
//         notification: registerData.notification,
//         photo: registerData.photo,
//       },
//     });

//     const { password, ...result } = user;

//     const options = { expiresIn: '1h', privateKey: process.env.JWTSECRET };
//     let auth = await this.login({ email: user.email, password: registerData.password }, options);
//     return auth;

//     // return result;
//   }
// }

import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from 'src/prisma/prisma.service';
import 'dotenv/config';
import { LoginDto } from './dtos/login.dto';
import { UserDto } from 'src/user/dtos/user.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService
  ) {}

  // Валідація користувача при логіні
  private async validateUser(email: string, pass: string) {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (user && await bcrypt.compare(pass, user.password)) {
      // Повертаємо дані без пароля
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  // Метод логіну
  async login(loginData: LoginDto) {
    const user = await this.validateUser(loginData.email, loginData.password);
    if (!user) {
      throw new UnauthorizedException('Невірні облікові дані');
    }

    const payload = { sub: user.id, email: user.email, role: user.role };
    const access_token = this.jwtService.sign(payload, {
      expiresIn: '1h',
      secret: process.env.JWTSECRET,
    });

    return { access_token, user };
  }

  // Метод реєстрації
  async register(registerData: UserDto) {
    // Генеруємо сіль і хешуємо пароль перед збереженням
    const saltRounds = 10;
    const salt = await bcrypt.genSalt(saltRounds);
    const hashedPassword = await bcrypt.hash(registerData.password, salt); // bcrypt.hash генерує хеш пароля[1]

    // Створюємо користувача з уже захешованим паролем
    const newUser = await this.prisma.user.create({
      data: {
        email: registerData.email,
        password: hashedPassword,
        role: registerData.role,
        name: registerData.name,
        phoneNumber: registerData.phoneNumber,
        bonusAccount: registerData.bonusAccount,
        notification: registerData.notification,
        photo: registerData.photo,
      },
    }); // prisma.user.create зберігає дані у БД, включно з хешем пароля[2]

    // Генеруємо токен для нового користувача
    const payload = { sub: newUser.id, email: newUser.email, role: newUser.role };
    const access_token = this.jwtService.sign(payload, {
      expiresIn: '1h',
      secret: process.env.JWTSECRET,
    }); // jwtService.sign створює JWT заїском з секретом[3]

    // Повертаємо токен і дані користувача (без пароля)
    const { password, ...userWithoutPassword } = newUser;
    return { access_token, user: userWithoutPassword };
  }
}
