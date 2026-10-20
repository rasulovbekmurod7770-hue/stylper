// Figma get_design_context output — node 2775:2953 "home-feed-2" variant = post with the Uniqlo cardigan tag TAPPED.
// File: Z6aHsxkD41lT8lZ8JiBsQv, fetched 2026-10-20. Screenshot: design/figma/screens/09b_post_tag_2775-2953.png (311×1024).
// The response is IDENTICAL to specs/09_post_2775-2840.tsx (same layout, styles, texts and asset files; node ids differ)
// except for the fragments below, which are copied verbatim:
//   1. the tapped tag's dot grows from 6px to 8px (762c0.svg → raw/post/tag_dot_active.svg) and moves 1px up-left;
//      the other dots keep 8a8f3.svg (raw/post/tag_dot.svg);
//   2. the "expanded-tag-card" is added inside Image-Frame, after the back button.
const imgCardiganDot = `${assetPathPrefix}/762c0.svg`;
const imgShirtDot = `${assetPathPrefix}/8a8f3.svg`;

            <div className="absolute left-[187px] size-[8px] top-[187px]" data-node-id="2775:2979" data-name="cardigan-dot">
              <img alt="" className="absolute block inset-0 max-w-none size-full" src={imgCardiganDot} />
            </div>

            <div className="absolute backdrop-blur-[9px] bg-[rgba(26,26,26,0.65)] border border-[rgba(26,26,26,0.4)] border-solid content-stretch flex flex-col gap-[12px] items-start left-[16px] p-[14px] rounded-[18px] shadow-[0px_10px_24px_0px_rgba(0,0,0,0.15)] top-[236px] w-[358px]" data-node-id="2775:2991" data-name="expanded-tag-card">
              <div className="[word-break:break-word] content-stretch flex flex-col gap-[4px] items-start leading-[normal] not-italic relative shrink-0 w-full" data-node-id="2775:2992" data-name="Frame">
                <p className="font-['Inter:Extra_Light'] font-extralight relative shrink-0 text-[#fafaf7] text-[12px] whitespace-nowrap" data-node-id="2775:2993">
                  Uniqlo
                </p>
                <p className="font-['Inter:Semi_Bold'] font-semibold min-w-full relative shrink-0 text-[#fafaf7] text-[14px] w-[min-content]" data-node-id="2775:2994">
                  Oversized Wool Cardigan
                </p>
                <p className="font-['Inter:Semi_Bold'] font-semibold relative shrink-0 text-[#fafaf7] text-[13px] whitespace-nowrap" data-node-id="2775:2995">
                  $89
                </p>
                <p className="font-['Inter:Regular'] font-normal min-w-full relative shrink-0 text-[#cacaca] text-[11px] w-[min-content]" data-node-id="2775:2996">
                  124 people styled this
                </p>
              </div>
              <div className="content-stretch flex gap-[8px] items-start relative shrink-0 w-full" data-node-id="2775:2997" data-name="Frame">
                <div className="bg-[rgba(26,26,26,0)] border border-[rgba(250,250,247,0.3)] border-solid content-stretch flex items-center justify-center px-[12px] py-[8px] relative rounded-[999px] shrink-0 w-[164px]" data-node-id="2775:2998" data-name="Frame">
                  <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#fafaf7] text-[11px] whitespace-nowrap" data-node-id="2775:2999">
                    See looks
                  </p>
                </div>
                <div className="bg-[#332e3d] content-stretch flex items-center justify-center px-[12px] py-[8px] relative rounded-[999px] shrink-0 w-[164px]" data-node-id="2775:3000" data-name="Frame">
                  <p className="[word-break:break-word] font-['Inter:Semi_Bold'] font-semibold leading-[normal] not-italic relative shrink-0 text-[#fafaf7] text-[11px] whitespace-nowrap" data-node-id="2775:3001">
                    Save
                  </p>
                </div>
              </div>
            </div>
