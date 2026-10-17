import type { NextFunction, Request, Response } from "express";

export const authorizeRoles = (...roles:string[])=>{
    return (req:Request,res:Response,next: NextFunction)=>{
        const userRole = (req.user)?.role;
        if(!userRole){
            res.status(401).json({message:"unauthorized"});
            return;
        }
        if(!roles.includes(userRole)){
            res.status(403).json({message:"forbidden no permission"});
            return;
        }
        next();
    }
}