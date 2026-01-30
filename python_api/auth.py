# auth.py
from fastapi import APIRouter, Depends, HTTPException, Response, Request
from sqlalchemy.orm import Session
from database import get_db
import crud, models, schemas, security
from fastapi import status

router = APIRouter(prefix="/auth", tags=["auth"])

REFRESH_COOKIE_NAME = "refresh_token"

def _set_refresh_cookie(resp: Response, token: str):
    resp.set_cookie(
        key=REFRESH_COOKIE_NAME,
        value=token,
        httponly=True,
        samesite="lax",
        secure=False,  # set to True in production with HTTPS
        max_age=60*60*24*7,
        path="/auth",
    )

def _clear_refresh_cookie(resp: Response):
    resp.delete_cookie(REFRESH_COOKIE_NAME, path="/auth")

@router.post("/login", response_model=schemas.TokenOut)
def login(body: schemas.LoginIn, response: Response, db: Session = Depends(get_db)):
    user = crud.get_counsellor_by_email(db, body.email)
    if not user or not security.verify_password(body.password, user.password_hash) or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    access = security.create_access_token(user.email)
    refresh = security.create_refresh_token(user.email)
    _set_refresh_cookie(response, refresh)
    return {"access_token": access, "user": {"id": user.id, "email": user.email, "name": user.name}}

@router.post("/refresh", response_model=schemas.TokenOut)
def refresh(request: Request, response: Response, db: Session = Depends(get_db)):
    cookie = request.cookies.get(REFRESH_COOKIE_NAME)
    if not cookie:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="No refresh token")
    payload = security.decode_token(cookie)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")
    email = payload.get("sub")
    user = crud.get_counsellor_by_email(db, email)
    if not user or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    new_refresh = security.create_refresh_token(email)
    _set_refresh_cookie(response, new_refresh)
    new_access = security.create_access_token(email)
    return {"access_token": new_access, "user": {"id": user.id, "email": user.email, "name": user.name}}

@router.post("/logout")
def logout(response: Response):
    _clear_refresh_cookie(response)
    return {"message": "Logged out"}

@router.get("/me", response_model=schemas.CounsellorOut)
def me(authorization: str = None, db: Session = Depends(get_db)):
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing token")
    token = authorization.split(" ", 1)[1]
    payload = security.decode_token(token)
    if not payload or payload.get("type") != "access":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    email = payload.get("sub")
    user = crud.get_counsellor_by_email(db, email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
