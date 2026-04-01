"use client";
import React from "react";

type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "secondary" | "outline" | "ghost";
  size?: "sm" | "md" | "lg";
  loading?: boolean;
  asChild?: boolean;
};

const variantClasses = {
  primary: "btn btn-primary",
  outline: "btn btn-outline-secondary",
  secondary: "btn bg-[var(--color-secondary)] text-white hover:brightness-95",
  ghost: "btn bg-transparent hover:bg-black/5 text-black",
};

const sizeClasses = {
  sm: "px-3 py-1.5 text-xs",
  md: "px-4 py-2 text-sm",
  lg: "px-5 py-2.5 text-base",
};

type AsChildProps = {
  className?: string;
  onClick?: React.MouseEventHandler<HTMLElement>;
  "aria-disabled"?: boolean;
};

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(function Button(
  { variant = "primary", size = "md", loading, className = "", children, asChild = false, disabled, ...props },
  ref,
) {
  const base = `${variantClasses[variant]} ${sizeClasses[size]} ${className}`.trim();

  // AsChild: permite usar Link o 'a' conservando comportamiento básico
  if (asChild && React.isValidElement(children)) {
    const child = children as React.ReactElement<AsChildProps>;
    const baseProps = child.props;
    const mergedClassName = `${base} ${baseProps.className || ""}`.trim();
    const clonedProps: AsChildProps = {
      className: mergedClassName,
      onClick: props.onClick ?? baseProps.onClick,
    };
    if (disabled || loading) clonedProps["aria-disabled"] = true;
    return React.cloneElement(child, clonedProps);
  }

  return (
    <button {...props} ref={ref} className={base} disabled={disabled || loading} aria-disabled={disabled || loading}>
      {loading ? <span>Cargando...</span> : children}
    </button>
  );
});

export default Button;
