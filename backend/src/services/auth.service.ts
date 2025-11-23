// ============================================
// Authentication Service
// ============================================

import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import prisma from '../config/database';
import config from '../config';
import { AppError } from '../middleware/errorHandler';
import { AuthPayload, TokenPair, UserResponse } from '../types';

export class AuthService {
  /**
   * Generate JWT access token
   */
  private generateAccessToken(userId: string, email: string): string {
    const payload: AuthPayload = { userId, email };
    return jwt.sign(payload, config.jwt.accessSecret, {
      expiresIn: config.jwt.accessExpiration,
    });
  }

  /**
   * Generate JWT refresh token
   */
  private generateRefreshToken(userId: string, email: string): string {
    const payload: AuthPayload = { userId, email };
    return jwt.sign(payload, config.jwt.refreshSecret, {
      expiresIn: config.jwt.refreshExpiration,
    });
  }

  /**
   * Generate token pair (access + refresh)
   */
  private async generateTokenPair(userId: string, email: string): Promise<TokenPair> {
    const accessToken = this.generateAccessToken(userId, email);
    const refreshToken = this.generateRefreshToken(userId, email);

    // Calculate expiration date (7 days from now)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    // Store refresh token in database
    await prisma.refreshToken.create({
      data: {
        id: uuidv4(),
        userId,
        token: refreshToken,
        expiresAt,
      },
    });

    return { accessToken, refreshToken };
  }

  /**
   * Register new user
   */
  async register(email: string, password: string): Promise<{ user: UserResponse; tokens: TokenPair }> {
    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new AppError(409, 'CONFLICT', 'User with this email already exists');
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user
    const user = await prisma.user.create({
      data: {
        id: uuidv4(),
        email,
        passwordHash,
      },
    });

    // Create default user settings
    await prisma.userSettings.create({
      data: {
        id: uuidv4(),
        userId: user.id,
        enableHapticFeedback: true,
        enableSoundEffects: true,
        showHeatmapByDefault: false,
      },
    });

    // Generate tokens
    const tokens = await this.generateTokenPair(user.id, user.email);

    // Return user without password hash
    const userResponse: UserResponse = {
      id: user.id,
      email: user.email,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };

    return { user: userResponse, tokens };
  }

  /**
   * Login user
   */
  async login(email: string, password: string): Promise<{ user: UserResponse; tokens: TokenPair }> {
    // Find user
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new AppError(401, 'UNAUTHORIZED', 'Invalid email or password');
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.passwordHash);

    if (!isValidPassword) {
      throw new AppError(401, 'UNAUTHORIZED', 'Invalid email or password');
    }

    // Generate tokens
    const tokens = await this.generateTokenPair(user.id, user.email);

    // Return user without password hash
    const userResponse: UserResponse = {
      id: user.id,
      email: user.email,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };

    return { user: userResponse, tokens };
  }

  /**
   * Refresh access token
   */
  async refresh(refreshToken: string): Promise<TokenPair> {
    // Verify refresh token
    let decoded: AuthPayload;
    try {
      decoded = jwt.verify(refreshToken, config.jwt.refreshSecret) as AuthPayload;
    } catch (error) {
      throw new AppError(401, 'UNAUTHORIZED', 'Invalid or expired refresh token');
    }

    // Check if refresh token exists in database
    const storedToken = await prisma.refreshToken.findUnique({
      where: { token: refreshToken },
    });

    if (!storedToken) {
      throw new AppError(401, 'UNAUTHORIZED', 'Refresh token not found');
    }

    // Check if token is expired
    if (storedToken.expiresAt < new Date()) {
      // Delete expired token
      await prisma.refreshToken.delete({
        where: { id: storedToken.id },
      });
      throw new AppError(401, 'UNAUTHORIZED', 'Refresh token expired');
    }

    // Verify user still exists
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
    });

    if (!user) {
      throw new AppError(401, 'UNAUTHORIZED', 'User not found');
    }

    // Delete old refresh token
    await prisma.refreshToken.delete({
      where: { id: storedToken.id },
    });

    // Generate new token pair
    const tokens = await this.generateTokenPair(user.id, user.email);

    return tokens;
  }

  /**
   * Logout user (revoke refresh token)
   */
  async logout(refreshToken: string): Promise<void> {
    await prisma.refreshToken.deleteMany({
      where: { token: refreshToken },
    });
  }

  /**
   * Get current user by ID
   */
  async getCurrentUser(userId: string): Promise<UserResponse> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError(404, 'NOT_FOUND', 'User not found');
    }

    return {
      id: user.id,
      email: user.email,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }
}

export default new AuthService();
