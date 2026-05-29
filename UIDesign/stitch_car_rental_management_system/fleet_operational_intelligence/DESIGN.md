---
name: Fleet Operational Intelligence
colors:
  surface: '#fbf8fc'
  surface-dim: '#dbd9dd'
  surface-bright: '#fbf8fc'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f6'
  surface-container: '#efedf1'
  surface-container-high: '#e9e7eb'
  surface-container-highest: '#e4e2e5'
  on-surface: '#1b1b1e'
  on-surface-variant: '#45464e'
  inverse-surface: '#303033'
  inverse-on-surface: '#f2f0f3'
  outline: '#75777f'
  outline-variant: '#c5c6cf'
  surface-tint: '#4e5e84'
  primary: '#041638'
  on-primary: '#ffffff'
  primary-container: '#1b2b4e'
  on-primary-container: '#8393bc'
  inverse-primary: '#b6c6f1'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#251400'
  on-tertiary: '#ffffff'
  tertiary-container: '#402700'
  on-tertiary-container: '#b38d5b'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d9e2ff'
  primary-fixed-dim: '#b6c6f1'
  on-primary-fixed: '#081a3d'
  on-primary-fixed-variant: '#37466b'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#ffddb5'
  tertiary-fixed-dim: '#eabf89'
  on-tertiary-fixed: '#2a1800'
  on-tertiary-fixed-variant: '#5e4116'
  background: '#fbf8fc'
  on-background: '#1b1b1e'
  surface-variant: '#e4e2e5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  title-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  status-badge:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 12px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  sidebar_width: 280px
  container_max_width: 1440px
  gutter: 24px
  margin_page: 32px
  stack_sm: 8px
  stack_md: 16px
  stack_lg: 24px
---

## Brand & Style
This design system is engineered for high-density data management and operational efficiency in the car rental sector. The aesthetic is **Corporate / Modern**, prioritizing clarity, reliability, and trust. The visual language utilizes a "Function over Form" philosophy, where every element serves a clear utility, reducing cognitive load for fleet managers.

The interface evokes a sense of organized precision through generous white space, a disciplined color palette, and systematic alignment. It balances the rigidity of enterprise software with the fluidity of modern SaaS to ensure long-term usability without visual fatigue.

## Colors
The palette is anchored by a deep Navy Blue, signaling authority and stability. We utilize a functional color system where hues are strictly reserved for semantic meaning:
- **Primary (Navy):** Used for global navigation, primary actions, and branding.
- **Surface (White/Light Gray):** A layered approach using `#F8FAFC` for the application backdrop and pure `#FFFFFF` for interactive cards to create a clear visual hierarchy.
- **Semantic (Green/Orange/Red):** Dedicated exclusively to vehicle status (Available, Maintenance, Booked/Error). 

Avoid using primary navy for non-interactive decorative elements to maintain the "actionable" meaning of the color.

## Typography
We use **Inter** for its exceptional legibility in data-heavy environments. The typographic scale is optimized for a 1440px dashboard environment.
- **Headlines:** Use Bold and Semi-Bold weights to anchor the page sections.
- **Body Text:** Standardized at 14px and 16px to ensure readability in dense tables and lists.
- **Data Tables:** Use `body-sm` for row content to maximize information density without sacrificing clarity.
- **Labels:** Uppercase labels with slight letter spacing are reserved for table headers and small metadata categories.

## Layout & Spacing
The layout follows a **Fixed Sidebar + Fluid Content** model. 
- **Sidebar:** Fixed at 280px. It contains the primary navigation and high-level fleet filters.
- **Grid:** A 12-column grid is used within the content area. Cards typically span 3 columns (for stats), 6 columns (for charts), or 12 columns (for data tables).
- **Rhythm:** An 8px base unit drives all spacing. Page margins are set to 32px to provide a premium, airy feel that prevents the enterprise data from feeling claustrophobic.

## Elevation & Depth
Depth is created through **Tonal Layering** supplemented by **Ambient Shadows**. 
- **Level 0 (Background):** `#F8FAFC` - The base canvas.
- **Level 1 (Cards/Surface):** Pure white with a subtle `0px 1px 3px rgba(0,0,0,0.1)` shadow. This is the primary container for all data.
- **Level 2 (Hover/Modals):** A more pronounced `0px 10px 15px -3px rgba(0,0,0,0.1)` shadow to indicate interactivity or focus.
- **Borders:** Use 1px solid `#E2E8F0` for internal card dividers and table rows, keeping the UI flat and structured.

## Shapes
This design system utilizes **Soft (Level 1)** roundedness. 
- **Buttons and Inputs:** 4px (0.25rem) corner radius. This conveys a professional, precise, and organized character.
- **Cards:** 8px (0.5rem) corner radius. 
- **Status Badges:** Fully rounded (pill-shaped) to distinguish them from interactive buttons and input fields.

## Components
### Buttons
- **Primary:** Solid Navy (#1B2B4E) with white text.
- **Secondary:** White background with Navy border and text.
- **Ghost:** No border, Navy text; used for secondary actions in tables.

### Status Badges
Badges use a "Tinted" style: a 10% opacity background of the semantic color with 100% opacity text of the same color (e.g., Success badge is light green background with dark green text). This ensures high legibility and soft visual integration.

### Data Tables
Tables are the heart of the system. 
- **Header:** Light gray background (#F1F5F9), uppercase labels.
- **Rows:** 56px minimum height, 1px bottom border.
- **Pagination:** Clean, numeric links with "Previous/Next" icons.

### Form Inputs
Standardized with 1px borders (#E2E8F0). On focus, the border transitions to Primary Navy with a 2px soft glow.

### Sidebar Navigation
The sidebar uses the Primary Navy as the background. Active states are indicated by a "left-border" accent in a lighter blue tint and a subtle background highlight to signify the current location.