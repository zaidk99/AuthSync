import express from "express";
import jwt from "jsonwebtoken";
import { ENV } from "../config/env.js";
import type { JwtPayload } from "../types/jwt.types.js";
import type {Request , Response , NextFunction} from "express";

export const authentication = (req:Request , res:Response , next:NextFunction)=>{
    const token = req.headers.authorization?.split(' ')[1];
    if(!token){
        res.status(401).json({message:"unauthorized"});
        return;
    }
    try {
        const decoded = jwt.verify(token,ENV.JWT_SECRET as string) as JwtPayload;
        req.user = decoded;
        next();
        
    } catch (error) {
        res.status(401).json({message:"invlid token"});
    }

};




