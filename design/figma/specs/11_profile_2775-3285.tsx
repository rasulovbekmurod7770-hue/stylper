// Figma get_design_context output (verbatim) — node 2775:3285 "Profile" (own profile, Posts tab)
// File: Z6aHsxkD41lT8lZ8JiBsQv, fetched 2026-10-20. Asset URLs expire 2026-10-27; assets live in
// design/figma/raw/profile_screen (raw/profile is the profile-SETUP form). Screenshot: design/figma/screens/11_profile_2775-3285.png (303×1024).
// Styles in design: "Stylper soft".
//   3408f.png avatar.png  14e83.png hero_look.png  463be.png look_1.png  b65fa.png look_2.png
//   d4a7a/db75a/e390b/021e5/30243.png thumb_{2..6}.png   (thumb-1 reuses look_1)
//   5a854.svg share_btn.svg  c59dd.svg settings_btn.svg  95e3d.svg stats_dot.svg  2e78a.svg dna_dot.svg
//   18295/0841f/3c2fa/f239a/074be.svg tab_{home,search,create,explore,profile_active}.svg   (status icons not downloaded)
const assetPathPrefix = "https://www.figma.com/api/mcp/asset/55023c77-d148-48f1-856a-d164e74f6a45";
const imgRectangle = `${assetPathPrefix}/3408f.png`;
const imgHeroLook = `${assetPathPrefix}/14e83.png`;
const imgLook1 = `${assetPathPrefix}/463be.png`;
const imgLook2 = `${assetPathPrefix}/b65fa.png`;
const imgThumb2 = `${assetPathPrefix}/d4a7a.png`;
const imgThumb3 = `${assetPathPrefix}/db75a.png`;
const imgThumb4 = `${assetPathPrefix}/e390b.png`;
const imgThumb5 = `${assetPathPrefix}/021e5.png`;
const imgThumb6 = `${assetPathPrefix}/30243.png`;
const imgFrame = `${assetPathPrefix}/cc828.svg`;
const imgFrame1 = `${assetPathPrefix}/cbcad.svg`;
const imgFrame2 = `${assetPathPrefix}/7b0ac.svg`;
const imgFrame3 = `${assetPathPrefix}/5a854.svg`;
const imgFrame4 = `${assetPathPrefix}/c59dd.svg`;
const imgEllipse = `${assetPathPrefix}/95e3d.svg`;
const imgEllipse1 = `${assetPathPrefix}/2e78a.svg`;
const imgIcons = `${assetPathPrefix}/18295.svg`;
const imgIcons1 = `${assetPathPrefix}/0841f.svg`;
const imgTabExplore = `${assetPathPrefix}/3c2fa.svg`;
const imgIcons2 = `${assetPathPrefix}/f239a.svg`;
const imgIcons3 = `${assetPathPrefix}/074be.svg`;

export default function Profile() {
  return (
    <div className="bg-[#fafaf7] overflow-clip relative rounded-[40px] size-full" data-node-id="2775:3285" data-name="Profile">
      <div className="absolute content-stretch flex h-[25px] items-center justify-between left-[20px] py-[4px] right-[20px] top-[12px]" data-node-id="2775:3286" data-name="status-bar">
        <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[14px] whitespace-nowrap" data-node-id="2775:3287">
          9:41
        </p>
        <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-node-id="2775:3288" data-name="Frame">
          <div className="h-[10px] relative shrink-0 w-[18px]" data-node-id="2775:3289" data-name="Frame">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgFrame} />
          </div>
          <div className="h-[12px] relative shrink-0 w-[16px]" data-node-id="2775:3291" data-name="Frame">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgFrame1} />
          </div>
          <div className="h-[12px] relative shrink-0 w-[24px]" data-node-id="2775:3293" data-name="Frame">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgFrame2} />
          </div>
        </div>
      </div>
      <div className="absolute content-stretch flex flex-col items-start left-[20px] pt-[8px] right-[20px] top-[57px]" data-node-id="2775:3295" data-name="hero-header">
        <div className="content-stretch flex items-center justify-between mb-[-5px] relative shrink-0 w-full" data-node-id="2775:3296" data-name="hero-top">
          <div className="bg-[#f2f2f0] border border-[rgba(26,26,26,0.07)] border-solid content-stretch flex flex-col items-center justify-center relative rounded-[18px] shrink-0 size-[36px]" data-node-id="2775:3297" data-name="btn">
            <div className="relative shrink-0 size-[18px]" data-node-id="2775:3298" data-name="Frame">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgFrame3} />
            </div>
          </div>
          <div className="bg-[#f2f2f0] border border-[rgba(26,26,26,0.07)] border-solid content-stretch flex flex-col items-center justify-center relative rounded-[18px] shrink-0 size-[36px]" data-node-id="2775:3300" data-name="btn">
            <div className="relative shrink-0 size-[18px]" data-node-id="2775:3301" data-name="Frame">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgFrame4} />
            </div>
          </div>
        </div>
        <div className="content-stretch flex flex-col gap-[14px] items-center pt-[4px] relative shrink-0 w-full" data-node-id="2775:3303" data-name="hero-content">
          <div className="bg-gradient-to-b border border-[rgba(26,26,26,0.08)] border-solid content-stretch flex flex-col from-[rgba(255,255,255,0.07)] items-center justify-center relative rounded-[48px] shrink-0 size-[96px] to-[rgba(255,255,255,0.03)]" data-node-id="2775:3304" data-name="avatar-shell">
            <div className="relative rounded-[44px] shrink-0 size-[88px]" data-node-id="2775:3305" data-name="Rectangle">
              <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[44px] size-full" src={imgRectangle} />
            </div>
          </div>
          <div className="[word-break:break-word] content-stretch flex flex-col gap-[6px] items-center leading-[normal] not-italic relative shrink-0 text-center w-full" data-node-id="2775:3306" data-name="identity">
            <p className="font-['Poppins:Bold'] relative shrink-0 text-[#1a1a1a] text-[30px] w-full" data-node-id="2775:3307">
              John. B
            </p>
            <p className="font-['Poppins:SemiBold'] relative shrink-0 text-[15px] text-[color:var(--stylper-1,#c11e38)] w-full" data-node-id="2775:3308">
              @John
            </p>
            <p className="font-['Inter:Regular'] font-normal relative shrink-0 text-[#807a87] text-[13px] w-full" data-node-id="2775:3309">
              Minimalist fashion lover | NYC
            </p>
          </div>
          <div className="content-stretch flex gap-[9.965px] items-center relative shrink-0" data-node-id="2775:3310" data-name="stats-row">
            <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[12.954px] whitespace-nowrap" data-node-id="2775:3311">
              48 Posts
            </p>
            <div className="relative shrink-0 size-[3.986px]" data-node-id="2775:3312" data-name="Ellipse">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgEllipse} />
            </div>
            <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[12.954px] whitespace-nowrap" data-node-id="2775:3313">
              1.2K Followers
            </p>
            <div className="relative shrink-0 size-[3.986px]" data-node-id="2775:3314" data-name="Ellipse">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgEllipse} />
            </div>
            <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[12.954px] whitespace-nowrap" data-node-id="2775:3315">
              340 Following
            </p>
          </div>
          <div className="content-stretch flex gap-[10px] items-center relative shrink-0 w-[292px]" data-node-id="2775:3316">
            <div className="border border-[rgba(26,26,26,0.14)] border-solid content-stretch flex h-[36px] items-center justify-center px-[16px] relative rounded-[999px] shrink-0 w-[140px]" data-node-id="2775:3317" data-name="edit-profile-btn">
              <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[12px] whitespace-nowrap" data-node-id="2775:3318">
                Edit Profile
              </p>
            </div>
            <div className="bg-gradient-to-b border border-[rgba(26,26,26,0.14)] border-solid content-stretch flex from-[var(--stylper-1,#c11e38)] h-[36px] items-center justify-center px-[16px] relative rounded-[999px] shrink-0 to-[#ff627b] w-[141px]" data-node-id="2775:3319" data-name="edit-profile-btn">
              <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[12px] whitespace-nowrap" data-node-id="2775:3320">
                My Wardrobe
              </p>
            </div>
          </div>
        </div>
      </div>
      <div className="absolute content-stretch flex flex-col gap-[14px] items-start left-[20px] right-[20px] top-[411px]" data-node-id="2775:3321" data-name="style-dna-section">
        <p className="[word-break:break-word] font-['Poppins:Bold'] leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[11px] tracking-[1.1px] uppercase whitespace-nowrap" data-node-id="2775:3322">
          STYLE DNA
        </p>
        <div className="content-start flex flex-wrap gap-[10px] items-start relative shrink-0 w-full" data-node-id="2775:3323" data-name="dna-tags">
          <div className="backdrop-blur-[8px] bg-[rgba(26,26,26,0.04)] border border-[rgba(26,26,26,0.08)] border-solid content-stretch flex gap-[8px] items-center px-[14px] py-[10px] relative rounded-[999px] shrink-0" data-node-id="2775:3324" data-name="Frame">
            <div className="relative shrink-0 size-[6px]" data-node-id="2775:3325" data-name="Ellipse">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgEllipse1} />
            </div>
            <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[12px] whitespace-nowrap" data-node-id="2775:3326">
              Minimal
            </p>
          </div>
          <div className="backdrop-blur-[8px] bg-[rgba(26,26,26,0.04)] border border-[rgba(26,26,26,0.08)] border-solid content-stretch flex gap-[8px] items-center px-[14px] py-[10px] relative rounded-[999px] shrink-0" data-node-id="2775:3327" data-name="Frame">
            <div className="relative shrink-0 size-[6px]" data-node-id="2775:3328" data-name="Ellipse">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgEllipse1} />
            </div>
            <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[12px] whitespace-nowrap" data-node-id="2775:3329">
              Casual
            </p>
          </div>
          <div className="backdrop-blur-[8px] bg-[rgba(26,26,26,0.04)] border border-[rgba(26,26,26,0.08)] border-solid content-stretch flex gap-[8px] items-center px-[14px] py-[10px] relative rounded-[999px] shrink-0" data-node-id="2775:3330" data-name="Frame">
            <div className="relative shrink-0 size-[6px]" data-node-id="2775:3331" data-name="Ellipse">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgEllipse1} />
            </div>
            <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[12px] whitespace-nowrap" data-node-id="2775:3332">
              Streetwear
            </p>
          </div>
          <div className="backdrop-blur-[8px] bg-[rgba(26,26,26,0.04)] border border-[rgba(26,26,26,0.08)] border-solid content-stretch flex gap-[8px] items-center px-[14px] py-[10px] relative rounded-[999px] shrink-0" data-node-id="2775:3333" data-name="Frame">
            <div className="relative shrink-0 size-[6px]" data-node-id="2775:3334" data-name="Ellipse">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgEllipse1} />
            </div>
            <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[12px] whitespace-nowrap" data-node-id="2775:3335">
              Neutral
            </p>
          </div>
          <div className="backdrop-blur-[8px] bg-[rgba(26,26,26,0.04)] border border-[rgba(26,26,26,0.08)] border-solid content-stretch flex gap-[8px] items-center px-[14px] py-[10px] relative rounded-[999px] shrink-0" data-node-id="2775:3336" data-name="Frame">
            <div className="relative shrink-0 size-[6px]" data-node-id="2775:3337" data-name="Ellipse">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgEllipse1} />
            </div>
            <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[12px] whitespace-nowrap" data-node-id="2775:3338">
              Oversized
            </p>
          </div>
        </div>
      </div>
      <div className="absolute content-stretch flex flex-col gap-[14px] items-start left-[20px] right-[20px] top-[548px]" data-node-id="2775:3339" data-name="my-style-section">
        <p className="[word-break:break-word] font-['Poppins:Bold'] leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[11px] tracking-[1.1px] uppercase whitespace-nowrap" data-node-id="2775:3340">
          MY STYLE
        </p>
        <div className="content-stretch flex gap-[12px] items-start relative shrink-0 w-full" data-node-id="2775:3341" data-name="style-collage">
          <div className="h-[320px] relative rounded-[20px] shrink-0 w-[224px]" data-node-id="2775:3342" data-name="hero-look">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[20px] size-full" src={imgHeroLook} />
          </div>
          <div className="content-stretch flex flex-col gap-[12px] items-start relative shrink-0 w-[112px]" data-node-id="2775:3343" data-name="side-looks">
            <div className="h-[154px] relative rounded-[20px] shrink-0 w-full" data-node-id="2775:3344" data-name="look-1">
              <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[20px] size-full" src={imgLook1} />
            </div>
            <div className="h-[154px] relative rounded-[20px] shrink-0 w-full" data-node-id="2775:3345" data-name="look-2">
              <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[20px] size-full" src={imgLook2} />
            </div>
          </div>
        </div>
      </div>
      <div className="absolute border-[rgba(26,26,26,0.07)] border-b border-solid content-stretch flex gap-[24px] h-[31px] items-center left-[20px] right-[20px] top-[919px]" data-node-id="2775:3346" data-name="tab-header">
        <div className="content-stretch flex flex-[1_0_0] flex-col gap-[8px] items-center justify-center min-w-px relative" data-node-id="2775:3347" data-name="tab-posts">
          <p className="[word-break:break-word] font-['Poppins:SemiBold'] leading-[normal] not-italic relative shrink-0 text-[#1a1a1a] text-[14px] whitespace-nowrap" data-node-id="2775:3348">
            Posts
          </p>
          <div className="bg-[var(--stylper-1,#c11e38)] h-[2px] relative rounded-[1px] shrink-0 w-[40px]" data-node-id="2775:3349" data-name="Rectangle" />
        </div>
        <div className="content-stretch flex flex-[1_0_0] flex-col items-center justify-center min-w-px relative" data-node-id="2775:3350" data-name="tab-saved">
          <p className="[word-break:break-word] font-['Poppins:Medium'] leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[14px] whitespace-nowrap" data-node-id="2775:3351">
            Saved
          </p>
        </div>
        <div className="content-stretch flex flex-[1_0_0] flex-col items-center justify-center min-w-px relative" data-node-id="2775:3352" data-name="tab-style-boards">
          <p className="[word-break:break-word] font-['Poppins:Medium'] leading-[normal] not-italic relative shrink-0 text-[#807a87] text-[14px] whitespace-nowrap" data-node-id="2775:3353">
            Style Boards
          </p>
        </div>
      </div>
      <div className="absolute content-stretch flex flex-col gap-[12px] items-start left-[20px] right-[20px] top-[970px]" data-node-id="2775:3354" data-name="posts-grid">
        <div className="content-stretch flex gap-[12px] items-start relative shrink-0 w-full" data-node-id="2775:3355" data-name="row-1">
          <div className="h-[114px] relative rounded-[18px] shrink-0 w-[112px]" data-node-id="2775:3356" data-name="thumb-1">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[18px] size-full" src={imgLook1} />
          </div>
          <div className="h-[114px] relative rounded-[18px] shrink-0 w-[112px]" data-node-id="2775:3357" data-name="thumb-2">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[18px] size-full" src={imgThumb2} />
          </div>
          <div className="h-[114px] relative rounded-[18px] shrink-0 w-[110px]" data-node-id="2775:3358" data-name="thumb-3">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[18px] size-full" src={imgThumb3} />
          </div>
        </div>
        <div className="content-stretch flex gap-[12px] items-start relative shrink-0 w-full" data-node-id="2775:3359" data-name="row-2">
          <div className="h-[114px] relative rounded-[18px] shrink-0 w-[112px]" data-node-id="2775:3360" data-name="thumb-4">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[18px] size-full" src={imgThumb4} />
          </div>
          <div className="h-[114px] relative rounded-[18px] shrink-0 w-[112px]" data-node-id="2775:3361" data-name="thumb-5">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[18px] size-full" src={imgThumb5} />
          </div>
          <div className="h-[114px] relative rounded-[18px] shrink-0 w-[110px]" data-node-id="2775:3362" data-name="thumb-6">
            <img alt="" className="absolute inset-0 max-w-none object-cover pointer-events-none rounded-[18px] size-full" src={imgThumb6} />
          </div>
        </div>
      </div>
      <div className="-translate-x-1/2 absolute bg-[#fafaf7] border border-[#424242] border-solid bottom-[25px] content-stretch drop-shadow-[0px_12px_12px_rgba(0,0,0,0.04)] flex gap-[16px] items-center justify-center left-1/2 p-[8px] rounded-[100px]" data-node-id="2775:3363" data-name="bottom-nav-container">
        <div className="content-stretch flex items-center justify-center p-[8px] relative rounded-[100px] shrink-0" data-node-id="2775:3364" data-name="tab-home">
          <div className="overflow-clip relative shrink-0 size-[24px]" data-node-id="2775:3365" data-name="Icons">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIcons} />
          </div>
        </div>
        <div className="content-stretch flex items-center justify-center p-[8px] relative rounded-[100px] shrink-0" data-node-id="2775:3366" data-name="tab-search">
          <div className="overflow-clip relative shrink-0 size-[24px]" data-node-id="2775:3367" data-name="Icons">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIcons1} />
          </div>
        </div>
        <div className="relative shrink-0 size-[32px]" data-node-id="2775:3368" data-name="tab-explore">
          <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgTabExplore} />
        </div>
        <div className="content-stretch flex items-center justify-center p-[8px] relative rounded-[100px] shrink-0" data-node-id="2775:3370" data-name="tab-explore">
          <div className="overflow-clip relative shrink-0 size-[24px]" data-node-id="2775:3371" data-name="Icons">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIcons2} />
          </div>
        </div>
        <div className="bg-gradient-to-b content-stretch flex from-[var(--stylper-1,#c11e38)] items-center justify-center p-[8px] relative rounded-[100px] shrink-0 to-[#ff627b]" data-node-id="2775:3372" data-name="tab-you">
          <div className="overflow-clip relative shrink-0 size-[24px]" data-node-id="2775:3373" data-name="Icons">
            <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgIcons3} />
          </div>
        </div>
      </div>
    </div>
  );
}
